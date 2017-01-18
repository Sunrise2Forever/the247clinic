class Api::V1::DoctorsController < Api::V1::AuthenticateController
  before_action :set_doctor, only: [:update, :show, :destroy]

  def index
    render json: Doctor.all, each_serializer: DoctorSerializer
  end

  def show
    render json: @doctor, serializer: DoctorSerializer
  end
  
  def update
    if @doctor.update(doctor_params)
      render json: @doctor, serializer: DoctorSerializer
    else
      render json: @doctor.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      render json: @doctor, serializer: DoctorSerializer
    else
      render json: @doctor.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @doctor.destroy
    render json: { result: 'success' }
  end

  private
     def doctor_params
      params.require(:doctor).permit(:name, :email, :phone, :mspnum, :birthdate, :password, :password_confirmation, :user_type, :clinic_id, not_working_days:[])
    end

    def set_doctor
      @doctor = Doctor.find_by(id: params[:id])
      render json: { result: 'fail' } if @doctor.nil?
    end
end
