class Api::V1::MessagesController < Api::V1::AuthenticateController
  before_action :set_message, only: [:update, :show, :destroy]

  def index
    render json: Message.all
  end

  def show
    render json: @message
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      render json: @message
    else
      render json: @message.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @message.destroy
    render json: { result: 'success' }
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:user_id, :message, :status)
    end

    def set_message
      @message = Message.find_by(id: params[:id])
      render json: { result: 'fail' } if @message.nil?
    end
end
