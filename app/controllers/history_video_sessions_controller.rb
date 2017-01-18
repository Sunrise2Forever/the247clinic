class HistoryVideoSessionsController < AuthenticateController
  def index
    @video_sessions = VideoSession.where('user_id = ? OR doctor_id = ?', current_user.id, current_user.id).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show
    @video_session = VideoSession.find_by(id: params[:id])
    redirect_to history_video_sessions_path if @video_session.nil? or (@video_session.user_id != current_user.id and @video_session.doctor_id != current_user.id)
    @photos = @video_session.photos
  end
end
