class PhotosController < AuthenticateController
  def create
    video_session = VideoSession.find_by(id: params[:video_session_id])
    if current_user.doctor? and video_session.doctor_id == current_user.id
      video_session.photos.create(params.permit(:photo_url))
      render json: { result: 'success' }, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end
end
