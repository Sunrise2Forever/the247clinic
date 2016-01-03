class AppointmentsController < AuthenticateController
  skip_before_action :logged_in_user, only: [:new, :create]

  def index
    if current_user.doctor?
      respond_to do |format|
        format.html { }
        format.json {
          @appointments = Appointment.active.where("(doctor_id IS NULL AND clinic_id IS NULL) OR doctor_id = #{current_user.id} OR clinic_id = #{current_user.clinic_id}")
          render json: @appointments, each_searilizer: AppointmentSerializer, root: false, status: :ok
        }
      end
    else
      @appointments = current_user.appointments.active
    end
  end

  def show
    @appointment = Appointment.active.where("(doctor_id IS NULL AND clinic_id IS NULL) OR doctor_id = #{current_user.id} OR clinic_id = #{current_user.clinic_id}").find_by(id: params[:id])
    render json: @appointment, serializer: AppointmentSerializer, root: false, status: :ok
  end

  def new
    @appointment = Appointment.new
  end

  def edit
    @appointment = current_user.appointments.find_by(id: params[:id])
  end

  # POST /appointments
  # POST /appointments.json
  def create
    if current_user
      @appointment = current_user.appointments.new(appointment_params)
    else
      @appointment = Appointment.new(appointment_custom_params)
      if @appointment.user_name.blank?
        flash[:danger] = "Name can't be blank"
        render :new
        return
      end
      if @appointment.email.blank?
        flash[:danger] = "Email can't be blank"
        render :new
        return
      end
    end
    @appointment.status = :active
    if @appointment.save
      flash[:success] = 'Appointment was successfully created.'
      if current_user
        redirect_to appointments_path
      else
        redirect_to root_path
      end
    else
      flash[:danger] = @appointment.errors.full_messages.first
      render :new
    end
  end

  def update
    @appointment = current_user.appointments.find_by(id: params[:id])
    if @appointment.update(appointment_params)
      flash[:success] = 'Appointment was successfully updated.'
      redirect_to appointments_path
    else
      flash[:danger] = @appointment.errors.full_messages.first
      render :edit
    end
  end

  def destroy
    @appointment = current_user.appointments.find_by(id: params[:id])
    @appointment.destroy
    flash[:success] = 'Appointment was successfully destroyed.'
    redirect_to appointments_path
  end

  def cancel
    @appointment = current_user.appointments.find_by(id: params[:id])
    if @appointment.update(status: :inactive)
      flash[:success] = 'Appointment was successfully canceled.'
    else
      flash[:danger] = @appointment.errors.full_messages.first
    end
    redirect_to appointments_path
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:clinic_id, :doctor_id, :start_time, :end_time)
    end

    def appointment_custom_params
      params.require(:appointment).permit(:email, :phone, :user_name, :clinic_id, :doctor_id, :start_time, :end_time)
    end
end
