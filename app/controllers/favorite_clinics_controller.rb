class FavoriteClinicsController < AuthenticateController
  def create
    @favorite_clinic = current_user.favorite_clinics.new(clinic_id: params[:clinic_id])
    if @favorite_clinic.save
      flash[:success] = 'Clinic was successfully added to favorites.'
    else
      flash[:danger] = @favorite_clinic.errors.full_messages.first
    end
    redirect_to favorite_clinics_path
  end

  def remove
    @clinic = current_user.favorite_clinics.where(clinic_id: params[:clinic_id]).destroy_all
    flash[:success] = 'Clinic was successfully removed from favorites.'
    redirect_to favorite_clinics_path
  end
end
