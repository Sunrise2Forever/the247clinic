class Api::V1::AuthenticateController < ActionController::Base
  before_action :authenticate

  def authenticate
    @current_user = User.find_by(authentication_token: params[:authentication_token])
    render json: 'Unauthorized', status: :unauthorized if @current_user.blank?
  end

  def current_user
    @current_user
  end
end
