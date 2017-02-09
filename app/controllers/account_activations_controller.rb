class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user

      opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
      token = opentok.generate_token ENV['OPENTOK_PRESENCE_SESSION_ID'], 
        { role: :subscriber, data: { id: current_user.id, user_type: current_user.user_type, name: current_user.name }.to_json}
      current_user.update(presence_token: token)

      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
