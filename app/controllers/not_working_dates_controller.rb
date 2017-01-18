class NotWorkingDatesController < AuthenticateController
  before_action :correct_user

  def new
    @not_working_date = NotWorkingDate.new
  end

  def create
    @not_working_date = current_user.not_working_dates.new(params[:not_working_dates])
    if @not_working_date.save
      flash[:success] = 'Date was successfully saved.'
      redirect_to edit_user_path(current_user)
    else
      flash[:danger] = @not_working_date.errors.full_messages.first
      render :new
    end
  end
  def destroy
    @not_working_date = current_user.not_working_dates.find_by(id: params[:id])
    @not_working_date.destroy
    flash[:success] = 'Date was successfully removed.'
    redirect_to edit_user_path(current_user)
  end
  

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def not_working_date_params
      params.require(:not_working_date).permit(:date)
    end

    def correct_user
      redirect_to root_path unless current_user.doctor?
    end
end
