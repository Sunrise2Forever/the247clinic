class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :reactivate]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :destroy, :show, :reactivate]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @not_working_days = Date::DAYNAMES
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @clinic = @user.clinic
    if @clinic.present? and @clinic.not_opening_days
      @not_working_days = Date::DAYNAMES - @clinic.not_opening_days
    else
      @not_working_days = Date::DAYNAMES
    end
  end

  def reactivate
    @user = User.find(params[:id])
    if @user
      if @user.activated?
        flash[:info] = "Already activated."
      elsif @user.save
        @user.send_activation_email
        flash[:info] = "Activation email has been sent."
      end
    end
    redirect_to root_url
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end    
  end

  def favorites
    if current_user.admin? or current_user.doctor?
      redirect_to(root_url)
    else
      @favorite_clinics = current_user.favorite_clinics.order(:clinic_id)
      @favorite_doctors = current_user.favorite_doctors.order(:doctor_id)
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :mspnum, :password, :password_confirmation,
          :address1, :address2, :city, :country, :provincestate, :zipcode, :phone, :gender, :birthdate, :user_type, :clinic_id, working_schedules_attributes:[:id, :_destroy, :weekly, :scheduled_day_of_week, :scheduled_date, :start_time, :end_time])
    end
        # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless (current_user.admin? || current_user?(@user))
    end 
       
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
