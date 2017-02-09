class Api::V1::AppointmentsController < Api::V1::AuthenticateController
  before_action :set_appointment, only: [:update, :show, :destroy]

  def index
    render json: Appointment.all
  end

  def show
    render json: @appointment
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if @appointment.save
      render json: @appointment
    else
      render json: @appointment.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @appointment.update(appointment_params)
      render json: @appointment
    else
      render json: @appointment.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    render json: { result: 'success' }
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:user_id, :clinic_id, :doctor_id, :email, :phone, :user_name, :start_time, :end_time, :status)
    end

    def set_appointment
      @appointment = Appointment.find_by(id: params[:id])
      render json: { result: 'fail' } if @appointment.nil?
    end
end
