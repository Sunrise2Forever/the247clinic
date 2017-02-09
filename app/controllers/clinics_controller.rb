class ClinicsController < AuthenticateController
  before_action :admin_user, only: [:create, :update, :destroy]

  def index
    @clinics = Clinic.all
  end

  def new
    @clinic = Clinic.new
  end

  def edit
    @clinic = Clinic.find_by(id: params[:id])
  end

  def show
    @clinic = Clinic.find_by(id: params[:id])
    render json: @clinic
  end

  def create
    @clinic = Clinic.new(clinic_params)
    if @clinic.save
      flash[:success] = 'Clinic was successfully created.'
      redirect_to clinics_path
    else
      flash[:danger] = @clinic.errors.full_messages.first
      render :new
    end
  end

  def update
    @clinic = Clinic.find_by(id: params[:id])
    if @clinic.update(clinic_params)
      flash[:success] = 'Clinic was successfully updated.'
      redirect_to clinics_path
    else
      flash[:danger] = @clinic.errors.full_messages.first
      render :edit
    end
  end

  def destroy
    @clinic = Clinic.find_by(id: params[:id])
    @clinic.destroy
    flash[:success] = 'Clinic was successfully destroyed.'
    redirect_to clinics_path
  end

  def favorite
    if current_user.admin? or current_user.doctor?
      redirect_to(root_url)
    else
      @favorite_clinics = current_user.favorite_clinics
      @clinics = Clinic.all
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def clinic_params
      params.require(:clinic).permit(:name, not_opening_days:[])
    end
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
