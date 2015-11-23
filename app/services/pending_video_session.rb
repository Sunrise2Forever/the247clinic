class PendingVideoSession
  def initialize(video_session_id)
    @video_session_id = video_session_id
  end

  def perform
    video_session = VideoSession.find_by(id: @video_session_id)
    if video_session and video_session.status == 'pending'
      call_back = video_session.call_back
      if call_back.nil?
        call_back = CallBack.create(user_id: video_session.user_id)
      end
      video_session.update(status: :callback, call_back_id: call_back.id)
    end
  end
end
