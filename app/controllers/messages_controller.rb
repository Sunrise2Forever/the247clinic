class MessagesController < AuthenticateController
  def new
    @message = Message.new
  end
  
  def create
    video_session = VideoSession.find_by(id: params[:id])
    if video_session and video_session.user_id == current_user.id
      @message = Message.new(params.require(:message).permit(:message))
      @message.user_id = current_user.id
      @message.status = :started
      if @message.save
        flash[:success] = "Leave message successfully"
        redirect_to '/messages'
      else
        flash[:danger] = @message.errors.full_messages.first
        render :new
      end
    else
      redirect_to video_sessions_path
    end
  end

  def show
    @message = Message.find_by(id: params[:id])
    redirect_to video_sessions_path if @message.user_id != current_user.id and !current_user.doctor?
  end

  def index
    if current_user.doctor?
      @messages = Message.started.paginate(page: params[:page], per_page: 10)
    else
      @messages = current_user.messages.started.paginate(page: params[:page], per_page: 10)
    end
  end

  def update
    @message = Message.find_by(id: params[:id])
    if @message and current_user.doctor?
      @message.update(status: :finished)
      flash[:success] = "End message successfully"
    end
    redirect_to '/messages'
  end
end
