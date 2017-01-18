class FavoriteDoctorsController < AuthenticateController
  def create
    @favorite_doctor = current_user.favorite_doctors.new(doctor_id: params[:doctor_id])
    if @favorite_doctor.save
      flash[:success] = 'Doctor was successfully added to favorites.'
    else
      flash[:danger] = @favorite_doctor.errors.full_messages.first
    end
    redirect_to favorite_doctors_path
  end

  def remove
    @doctor = current_user.favorite_doctors.where(doctor_id: params[:doctor_id]).destroy_all
    flash[:success] = 'Doctor was successfully removed from favorites.'
    redirect_to favorite_doctors_path
  end
end
