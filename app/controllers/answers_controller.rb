class AnswersController < AuthenticateController

  def create
    message = Message.find_by(id: params[:id])
    if message and (message.user_id == current_user.id or current_user.doctor?)
      answer = message.answers.new(params.require(:answer).permit(:message))
      answer.user_id = current_user.id
      if answer.save
        flash.clear
      else
        flash[:danger] = answer.errors.full_messages.first
      end
      redirect_to message_path(message)
    else
      redirect_to video_sessions_path
    end
  end

end
