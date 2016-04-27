class Api::V1::OpentokSessionsController< Api::V1::AuthenticateController
  before_action :set_video_session, only: [:show]

  def show
    @video_session = VideoSession.find_by(id: params[:id])
    if @video_session.opentok_session.try(:token).blank?
      opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
      session = opentok.create_session :media_mode => :routed
      token = session.generate_token
      @video_session.create_opentok_session(session_id: session.session_id, token: token)
    elsif @video_session.opentok_session.updated_at < 24.hours.ago
      opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
      token = opentok.generate_token @video_session.opentok_session.session_id
      @video_session.opentok_session.update(token: token)      
    end
    render json: {
               opentok_session: {
                   api_key: ENV['OPENTOK_API_KEY'],
                   session_id: @video_session.opentok_session.session_id,
                   token: @video_session.opentok_session.token
               }
           }
  end

  def set_video_session
    @video_session = VideoSession.find_by(id: params[:id])
    render json: { result: 'fail' } if @video_session.nil?
  end

end
