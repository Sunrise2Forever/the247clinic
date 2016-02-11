class Api::V1::UsersController < Api::V1::AuthenticateController
  skip_before_action :authenticate, only: :create
  before_action :set_user, only: [:update]

  def update
    if @user.update(user_update_params)
      render json: @user
    else
      render json: @user.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user
    else
      render json: @user.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :phone, :mspnum, :birthdate, :password, :password_confirmation)
    end

    def user_update_params
      params.require(:user).permit(:name, :email, :phone, :mspnum, :birthdate, :password, :password_confirmation, :clinic_id, not_working_days:[])
    end

    def set_user
      @user = User.find_by(id: params[:id])
      if @user.blank? or @user.id != current_user['id']
        render json: { error: 'Invalid user' }
      end
    end
end
