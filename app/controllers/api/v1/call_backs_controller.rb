class Api::V1::CallBacksController < Api::V1::AuthenticateController
  before_action :set_call_back, only: [:update, :show, :destroy]

  def index
    render json: CallBack.all
  end

  def show
    render json: @call_back
  end

  def create
    @call_back = CallBack.new(call_back_params)
    if @call_back.save
      render json: @call_back
    else
      render json: @call_back.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @call_back.update(call_back_params)
      render json: @call_back
    else
      render json: @call_back.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @call_back.destroy
    render json: { result: 'success' }
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def call_back_params
    params.require(:call_back).permit(:user_id, :doctor_id, :scheduled_time)
  end

  def set_call_back
    @call_back = CallBack.find_by(id: params[:id])
    render json: { result: 'fail' } if @call_back.nil?
  end
end
