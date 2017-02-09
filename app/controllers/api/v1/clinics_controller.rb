class Api::V1::ClinicsController < Api::V1::AuthenticateController
  before_action :set_clinic, only: [:update, :show, :destroy]

  def index
    render json: Clinic.all
  end

  def show
    render json: @clinic
  end

  def create
    @clinic = Clinic.new(clinic_params)
    if @clinic.save
      render json: @clinic
    else
      render json: @clinic.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @clinic.update(clinic_params)
      render json: @clinic
    else
      render json: @clinic.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @clinic.destroy
    render json: { result: 'success' }
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def clinic_params
      params.require(:clinic).permit(:name, not_opening_days:[])
    end

    def set_clinic
      @clinic = Clinic.find_by(id: params[:id])
      render json: { result: 'fail' } if @clinic.nil?
    end
end
