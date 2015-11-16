class VideoSessionsController < ApplicationController
  before_action :logged_in_user

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
    @video_sessions = VideoSession.pending.where.not(user_id: current_user.id)
  end

  def show
    @video_session = VideoSession.pending.find_by(id: params[:id])
    if @video_session
      @is_doctor =  (@video_session.user_id != current_user.id)
      if @is_doctor and @video_session.status == 'pending'
        @video_session.status = :started
        @video_session.start_time = Time.now
        @video_session.save
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

  def finish
    @video_session = VideoSession.find_by(id: params[:id])

    if @video_session and (@video_session.status == 'started' or @video_session.status == 'pending')
      @is_doctor =  (@video_session.user_id != current_user.id)
      if @is_doctor
        @video_session.notes = params[:video_session][:notes]
        @video_session.finish_time = Time.now
        @video_session.status = :finished
        @video_session.save
        redirect_to root_path
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
      redirect_to root_path
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
      redirect_to root_path
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
      redirect_to root_path
    else
      flash[:danger] = @video_session.errors.full_messages.first
      render :feedback
    end
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

end
