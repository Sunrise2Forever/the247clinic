class Api::V1::VideoSessionsController < Api::V1::AuthenticateController
  before_action :set_video_session, only: [:update, :show, :destroy]

  def create
    @video_session = VideoSession.new(video_session_params)
    if @video_session.save
      render json: @video_session
    else
      render json: @video_session.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def index
    @video_sessions = VideoSession.all
    render json: @video_sessions.order(created_at: :desc)
  end

  def show
    render json: @video_session
  end

  def update
    if @video_session.update(video_session_params)
      render json: @video_session
    else
      render json: @video_session.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @video_session.destroy
    render json: { result: 'success' }
  end

  private
  def video_session_params
    params.require(:video_session).permit(:user_id, :symptom, :doctor_id, :start_time, :finish_time, :status, :notes)
  end

  def set_video_session
    @video_session = VideoSession.find_by(id: params[:id])
    render json: { result: 'fail' } if @video_session.nil?
  end
end
