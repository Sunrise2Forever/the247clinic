class CallBacksController < AuthenticateController
  before_action :correct_user, only: [:edit, :update, :destroy]
  def new
    @call_back = CallBack.new
  end
  
  def create
    video_session = VideoSession.find_by(id: params[:id])
    if video_session
      redirect_to video_sessions_path and return if video_session.status == 'waiting'
      if video_session.user_id == current_user.id
        @call_back = video_session.call_back
        if @call_back.nil?
          @call_back = CallBack.new(user_id: current_user.id)
          if @call_back.save
            video_session.update(status: :callback)
            flash[:success] = "Leave Call Back successfully"
            respond_to do |format|
              format.html { redirect_to video_sessions_path }
              format.json { render json: {} }
            end
          else
            flash[:danger] = @call_back.errors.full_messages.first
            render :new
          end
        else
          flash[:success] = "Leave Call Back successfully"
          respond_to do |format|
            format.html { redirect_to video_sessions_path }
            format.json { render json: {} }
          end
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

    if @call_back.doctor_id.nil?
      @call_back.doctor_id = current_user.id
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

  def show
    call_back = CallBack.find_by(id: params[:id])
    respond_to do |format|
      format.html { 
        if call_back and (call_back.user_id == current_user.id or call_back.doctor_id == current_user.id) and call_back.scheduled_time <= Time.zone.now
          video_session = call_back.video_session
          if video_session.nil?
            video_session = call_back.create_video_session(user_id: call_back.user_id, symptom: 'Scheduled Call Back', status: :pending)
          end
          redirect_to video_session_path(video_session) 
        else
          redirect_to video_sessions_path
        end
      }
      format.json { render json: call_back, root: false }
    end      
  end

  def correct_user
    @call_back = CallBack.find_by(id: params[:id])
    redirect_to video_sessions_path if @call_back.nil? or !current_user.doctor? or (@call_back.doctor_id.present? and @call_back.doctor_id != current_user.id)
  end
end
