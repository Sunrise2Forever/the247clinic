class VideoSessionsController < AuthenticateController

  def new

  end
  
  def create
    video_session = current_user.video_sessions.new(params.require(:video_session).permit(:symptom))
    video_session.status = :pending
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
      @video_sessions = VideoSession.pending.where.not(user_id: current_user.id)
                            .joins('LEFT JOIN call_backs ON call_backs.id = call_back_id')
                            .where('call_back_id IS NULL OR call_backs.doctor_id = ?', current_user.id)
      @call_backs = CallBack.all
    else
      @call_backs = CallBack.where('call_backs.user_id = ?', current_user.id)
    end
    @call_backs = @call_backs.joins('LEFT JOIN video_sessions ON call_backs.id = video_sessions.call_back_id')
                       .where("video_sessions.status IS NULL OR (video_sessions.status <> 'finished' AND video_sessions.status <> 'callback')")
                       .paginate(page: params[:page], per_page: 10)
  end

  def show
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session
      @is_doctor =  (@video_session.user_id != current_user.id and current_user.doctor?)
      if @is_doctor and @video_session.status == 'pending'
        @video_session.status = :started
        @video_session.start_time = Time.zone.now
        @video_session.doctor_id = current_user.id
        @video_session.save
      end
      if @video_session.status != 'started' and @video_session.status != 'pending'
        redirect_to video_sessions_path
      end
      if @video_session.status == 'started' and @video_session.user_id != current_user.id and @video_session.doctor_id != current_user.id
        redirect_to video_sessions_path
      end

      if current_user.doctor?
        set_s3_direct_post
        @photo = Photo.new
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

    if @video_session and (@video_session.status == 'started' or @video_session.status == 'pending')
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

  private
  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end

end
