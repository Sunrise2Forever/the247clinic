class CallBacksController < AuthenticateController
  before_action :correct_user, only: [:edit, :update, :destroy]
  def new
    @call_back = CallBack.new
  end
  
  def create
    video_session = VideoSession.find_by(id: params[:id])
    if video_session
      if video_session.user_id == current_user.id
        @call_back = CallBack.new(user_id: current_user.id)
        if @call_back.save
          flash[:success] = "Leave Call Back successfully"
          redirect_to video_sessions_path
        else
          flash[:danger] = @call_back.errors.full_messages.first
          render :new
        end
        return
      elsif video_session.doctor_id == current_user.id
        @call_back = CallBack.new(params.require(:call_back).permit(:scheduled_time))
        if @call_back.scheduled_time.nil?
          flash[:danger] = "Scheduling time can't be blank"
          render :new
        else
          @call_back.doctor_id = current_user.id
          @call_back.user_id = video_session.user_id
          if @call_back.save
            CallBackMailer.meeting_request_doctor(@call_back).deliver
            CallBackMailer.meeting_request_user(@call_back).deliver
            flash[:success] = "Scheduled Call Back successfully"
            redirect_to video_sessions_path
          else
            flash[:danger] = @call_back.errors.full_messages.first
            render :new
          end
        end
        return
      end
    end
    redirect_to video_sessions_path if @call_back.nil?
  end

  def update
    @call_back.scheduled_time = params[:call_back][:scheduled_time]
    if @call_back.scheduled_time.nil?
      flash[:danger] = "Scheduling time can't be blank"
      render :new
      return
    end

    if @call_back.save
      flash[:success] = "Updated Call Back successfully"
      redirect_to video_sessions_path
    else
      flash[:danger] = @call_back.errors.full_messages.first
      render :edit
    end
  end

  def destroy
    @call_back.destroy
    flash[:success] = "Deleted Call Back successfully"
    redirect_to video_sessions_path
  end

  def correct_user
    @call_back = CallBack.find_by(id: params[:id])
    redirect_to video_sessions_path if @call_back.nil? or @call_back.doctor_id != current_user.id
  end
end
