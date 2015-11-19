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
    if params[:type] == 'history'
      @video_sessions = VideoSession.where('user_id = ? OR doctor_id = ?', current_user.id, current_user.id).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
      render 'history'
      return
    end
    @video_sessions = VideoSession.pending.where.not(user_id: current_user.id)
    @call_backs = CallBack.where('user_id = ? OR doctor_id = ?', current_user.id, current_user.id)
  end

  def show
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session
      @is_doctor =  (@video_session.user_id != current_user.id)
      if @is_doctor and @video_session.status == 'pending'
        @video_session.status = :started
        @video_session.start_time = Time.now
        @video_session.doctor_id = current_user.id
        @video_session.save
      end
      if @video_session.status != 'started' and @video_session.status != 'pending'
        redirect_to video_sessions_path
      end
      if @video_session.status == 'started' and @video_session.user_id != current_user.id and @video_session.doctor_id != current_user.id
        redirect_to video_sessions_path
      end
    end
  end

  def edit
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def message
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def callback
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def feedback
    @video_session = current_user.video_sessions.find_by(id: params[:id])
  end

  def notes
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.status != 'finished' or @video_session.doctor_id != current_user.id
      redirect_to video_sessions_path
    end
  end

  def finish
    @video_session = VideoSession.find_by(id: params[:id])

    if @video_session and (@video_session.status == 'started' or @video_session.status == 'pending')
      @is_doctor =  (@video_session.user_id != current_user.id)
      if @is_doctor
        @video_session.notes = params[:video_session][:notes]
        @video_session.finish_time = Time.now
        @video_session.status = :finished
        @video_session.save
        redirect_to video_sessions_path
      else
        @video_session.finish_time = Time.now
        @video_session.status = :finished
        @video_session.save
        render :feedback
      end
    end
  end

  def update_message
    @video_session = current_user.video_sessions.find_by(id: params[:id])
    @video_session.message = params[:video_session][:message]
    @video_session.status = :left
    if @video_session.message.blank?
      flash[:danger] = "Message can't be blank"
      render :message
    elsif  @video_session.save
      flash[:success] = "Leave message successfully"
      redirect_to video_sessions_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :message
    end
  end

  def update_callback
    @video_session = current_user.video_sessions.find_by(id: params[:id])
    @video_session.callback = params[:video_session][:callback]
    @video_session.status = :left
    if @video_session.callback.blank?
      flash[:danger] = "Callback can't be blank"
      render :callback
    elsif @video_session.save
      flash[:success] = "Leave callback successfully"
      redirect_to video_sessions_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :callback
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
      redirect_to video_sessions_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :feedback
    end
  end

  def update_notes
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.status != 'finished' or @video_session.doctor_id != current_user.id
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

end
