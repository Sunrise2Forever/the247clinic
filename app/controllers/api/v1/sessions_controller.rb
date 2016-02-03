class Api::V1::SessionsController < ActionController::Base
  def create
    user = User.find_by(user_params.permit(:email))
    return invalid_login_attempt unless user

    # if success, sign in and respond
    if user.authenticate(user_params[:password])
      render json: user, status: :ok
      return
    end
    # login failed
    invalid_login_attempt
  end

  protected
    def user_params
      params.require(:user).permit(:email, :password)
    end

    # response when login failed
    def invalid_login_attempt
      render json: { error: 'Invalid email or password'}, status: :ok
    end
end
