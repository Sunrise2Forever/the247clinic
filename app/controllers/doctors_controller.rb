class DoctorsController < AuthenticateController
  def favorite
    if current_user.admin? or current_user.doctor?
      redirect_to(root_url)
    else
      @favorite_doctors = current_user.favorite_doctors
      @doctors = Doctor.all
    end
  end
end
