require 'opentok'

class VideoSessionsController < AuthenticateController

  def new

  end
  
  def create
    if params[:online_visit].present?
      if current_user.csr?
        video_session = current_user.video_sessions.new(doctor_id: current_user.id, status: :online, symptom: 'Online Visit')
      else
        video_session = current_user.video_sessions.new(status: :pending, symptom: 'Online Visit')
      end
    else
      video_session = current_user.video_sessions.new(params.require(:video_session).permit(:symptom))
      video_session.status = :pending
    end
    
    if video_session.save
      flash.clear
      redirect_to video_session_path(video_session.id)
    else
      flash[:danger] = video_session.errors.full_messages.first
      render :new
    end
  end

  def index
    if current_user.doctor?
      @video_sessions = VideoSession.where("video_sessions.status = 'pending' OR video_sessions.status = 'waiting'").where.not(user_id: current_user.id)
                            .joins('LEFT JOIN call_backs ON call_backs.id = call_back_id')
                            .where('call_back_id IS NULL OR call_backs.doctor_id = ?', current_user.id)
                            .paginate(page: params[:scheduled_visit_page], per_page: 10)

      @call_backs = CallBack.all
      @tasks = Task.where(doctor_id: current_user.id).order(created_at: :desc)
    elsif current_user.csr?
      @video_sessions = VideoSession.pending.where.not(user_id: current_user.id)
                            .joins('LEFT JOIN call_backs ON call_backs.id = call_back_id')
                            .where('call_back_id IS NULL OR call_backs.doctor_id = ?', current_user.id)
                            .paginate(page: params[:scheduled_visit_page], per_page: 10)

      @call_backs = CallBack.all                            
    else
      @video_sessions = VideoSession.waiting.where(user_id: current_user.id)
                            .paginate(page: params[:scheduled_visit_page], per_page: 10)

      @call_backs = CallBack.where('call_backs.user_id = ?', current_user.id)
    end

    @call_backs = @call_backs.joins('LEFT JOIN video_sessions ON call_backs.id = video_sessions.call_back_id')
                       .where("video_sessions.status IS NULL OR (video_sessions.status <> 'finished' AND video_sessions.status <> 'callback')")

    @online_visits = OnlineVisit.where('online_visits.user_id = ? OR online_visits.csr_id = ?', current_user.id, current_user.id)
                       .joins('LEFT JOIN video_sessions ON online_visits.id = video_sessions.call_back_id')
                       .where("video_sessions.status IS NULL OR (video_sessions.status <> 'finished' AND video_sessions.status <> 'callback')")                       

  end

  def show
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session
      if @video_session.status == 'online'
        if current_user.csr?           
          redirect_to video_sessions_path and return if @video_session.doctor_id != current_user.id
          @is_csr = true
        else
          if @video_session.user_id == @video_session.doctor_id
            @video_session.update(user_id: current_user.id)
          else
            redirect_to video_sessions_path and return if @video_session.user_id != current_user.id
          end
        end
      else
        if current_user.csr? 
          if @video_session.status == 'pending'
            @video_session.update(status: :online, start_time: Time.zone.now, doctor_id: current_user.id)
            @is_csr = true
          else
            redirect_to video_sessions_path and return
          end
        else
          @is_doctor =  (@video_session.user_id != current_user.id and current_user.doctor?)
          if @is_doctor and (@video_session.status == 'pending' or @video_session.status == 'waiting')
            @video_session.status = :started
            @video_session.start_time = Time.zone.now
            @video_session.doctor_id = current_user.id
            @video_session.save
          end
          if @video_session.status != 'started' and @video_session.status != 'pending' and @video_session.status != 'online' and @video_session.status != 'waiting'
            redirect_to video_sessions_path and return
          end
          if @video_session.status == 'started' and @video_session.user_id != current_user.id and @video_session.doctor_id != current_user.id
            redirect_to video_sessions_path and return
          end
        end
      end

      try_count = 0
      while @token.blank? and try_count < 10
        begin
          if @video_session.opentok_session.try(:token).blank?
            opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
            session = opentok.create_session :media_mode => :routed
            @token = session.generate_token
            @video_session.create_opentok_session(session_id: session.session_id, token: @token)
          elsif @video_session.opentok_session.updated_at < 24.hours.ago
            opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
            session = opentok.create_session :media_mode => :routed
            @token = session.generate_token
            @video_session.opentok_session.update(session_id: session.session_id, token: @token)      
          end
          @token = @video_session.opentok_session.try(:token)
        rescue => e
          try_count += 1
        end
      end

      if @is_doctor
        set_s3_direct_post
        @photo = Photo.new
        @tasks = Task.where(doctor_id: current_user.id).order(created_at: :desc)
        @video_session.notes ||= "<strong>Subjective</strong>:<br><br><strong>Objective</strong>:<br><br><strong>Assessment</strong>:<br><br><strong>Plan</strong>:<br><br>"
      end
    end
  end

  def edit
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def feedback
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def notes
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
  end

  def finish
    @video_session = VideoSession.find_by(id: params[:id])

    if @video_session and (@video_session.status == 'started' or @video_session.status == 'pending' or @video_session.status == 'online')
      if current_user.csr? and @video_session.doctor_id == current_user.id
        @video_session.finish_time = Time.zone.now
        @video_session.status = :finished
        @video_session.save
        redirect_to video_sessions_path
      else
        @is_doctor =  (@video_session.user_id != current_user.id)
        if @is_doctor
          @video_session.notes = params[:video_session][:notes]
          @video_session.finish_time = Time.zone.now
          @video_session.status = :finished
          @video_session.save
          redirect_to video_sessions_path
        else
          @video_session.finish_time = Time.zone.now
          @video_session.status = :finished
          @video_session.save
          render :feedback
        end
      end
    else
      redirect_to video_sessions_path
    end
  end

  def update_feedback
    @video_session = current_user.video_sessions.find_by(id: params[:id])
    @video_session.feedback = params[:video_session][:feedback]
    if @video_session.feedback.blank?
      flash[:danger] = "Feedback can't be blank"
      render :feedback
    elsif @video_session.save
      flash[:success] = "Submit feedback successfully"
      redirect_to root_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :feedback
    end
  end

  def update_notes
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
    @video_session.notes = params[:video_session][:notes]
    if @video_session.notes.blank?
      flash[:danger] = "Notes can't be blank"
      render :notes
    elsif @video_session.save
      flash[:success] = "Write notes successfully"
      redirect_to video_sessions_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :notes
    end
  end

  def sign_off
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
    @video_session.sign_off = true
    if @video_session.save
      render json: @video_session
    else
      render json: @video_session.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def add_diagnosis
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
    @video_session.diagnosis = @video_session.diagnosis.to_s + params[:video_session][:diagnosis].to_s + '<br>'
    if @video_session.save
      render json: @video_session
    else
      render json: @video_session.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def save
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
    @video_session.notes = params[:video_session][:notes]
    if @video_session.save
      Task.create(doctor_id: current_user.id, title: "Sign off on  #{@video_session.user.try(:name)}'s #{@video_session.created_at.strftime("%B %-d %I:%M %P")} Visit")
      render json: @video_session
    else
      render json: @video_session.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def export
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
    export_string = '<strong>Notes</strong><br>' + @video_session.notes.to_s + '<br><strong>Diagnosis</strong><br>' + @video_session.diagnosis.to_s
    respond_to do |format|
      format.pdf { send_data WickedPdf.new.pdf_from_string(export_string) }
      format.rtf { send_data export_string }
    end
  end

  def transfer
    @video_session = VideoSession.find_by(id: params[:id])
    if current_user.csr? and current_user.id = @video_session.doctor_id and @video_session.status == 'online'
      @video_session.update(doctor_id: params[:doctor_id], status: :pending)
      render json: @video_session
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def wait
    @video_session = VideoSession.find_by(id: params[:id])
    if current_user.csr? and current_user.id = @video_session.doctor_id and @video_session.status == 'online'
      @video_session.update(doctor_id: nil, status: :waiting)
    end
    redirect_to video_sessions_path
  end

  private
  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end

end
