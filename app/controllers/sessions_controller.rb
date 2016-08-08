class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)

        opentok = OpenTok::OpenTok.new ENV['OPENTOK_API_KEY'], ENV['OPENTOK_SECRET']
        token = opentok.generate_token ENV['OPENTOK_PRESENCE_SESSION_ID'], 
          { role: :subscriber, data: { id: current_user.id, user_type: current_user.user_type, name: current_user.name }.to_json}
        current_user.update(presence_token: token)

        if user.doctor?
          redirect_to video_sessions_path
        else
          redirect_to root_path
        end
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email and/or password' # Not quite right!
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
