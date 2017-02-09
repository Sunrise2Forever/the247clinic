class OnlineVisitsController < AuthenticateController
  before_action :correct_user, only: [:edit, :update, :destroy]
  def new
    @online_visit = OnlineVisit.new
  end
  
  def create
    video_session = VideoSession.find_by(id: params[:id])
    if video_session
      @online_visit = OnlineVisit.new(params.require(:online_visit).permit(:scheduled_time))
      if @online_visit.scheduled_time.nil?
        flash[:danger] = "Scheduling time can't be blank"
        render :new
      else
        @online_visit.csr_id = current_user.id
        @online_visit.user_id = video_session.user_id
        if @online_visit.save
          flash[:success] = "Scheduled Online Visit successfully"
          redirect_to video_sessions_path
        else
          flash[:danger] = @online_visit.errors.full_messages.first
          render :new
        end
      end
      return
    end
    redirect_to video_sessions_path if @online_visit.nil?
  end

  def update
    @online_visit.scheduled_time = params[:online_visit][:scheduled_time]
    if @online_visit.scheduled_time.nil?
      flash[:danger] = "Scheduling time can't be blank"
      render :new
      return
    end

    if @online_visit.csr_id.nil?
      @online_visit.csr_id = current_user.id
    end
    if @online_visit.save
      flash[:success] = "Updated Online Visit successfully"
      redirect_to video_sessions_path
    else
      flash[:danger] = @online_visit.errors.full_messages.first
      render :edit
    end
  end

  def destroy
    @online_visit.destroy
    flash[:success] = "Deleted Online Visit successfully"
    redirect_to video_sessions_path
  end

  def show
    online_visit = OnlineVisit.find_by(id: params[:id])
    respond_to do |format|
      format.html { 
        if online_visit and (online_visit.user_id == current_user.id or online_visit.csr_id == current_user.id) and online_visit.scheduled_time <= Time.zone.now
          video_session = online_visit.video_session
          if video_session.nil?
            video_session = online_visit.create_video_session(user_id: online_visit.user_id, doctor_id: online_visit.csr_id, symptom: 'Scheduled Online Visit', status: :online)
          end
          redirect_to video_session_path(video_session)
        else
          redirect_to video_sessions_path
        end
      }
      format.json { render json: online_visit, root: false }
    end    
  end

  def correct_user
    @online_visit = OnlineVisit.find_by(id: params[:id])
    redirect_to video_sessions_path if @online_visit.nil? or !current_user.csr? or (@online_visit.csr_id.present? and @online_visit.csr_id != current_user.id)
  end
end
