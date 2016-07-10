class WorkingSchedulesController < AuthenticateController
  before_action :correct_user
  before_action :set_working_schedule, only: [:show, :edit, :update, :destroy]

  # GET /working_schedules
  # GET /working_schedules.json
  def index
    @working_schedules = WorkingSchedule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @working_schedules }
    end
  end

  # GET /working_schedules/1
  # GET /working_schedules/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @working_schedule }
    end
  end

  # GET /working_schedules/new
  def new
    @working_schedule = WorkingSchedule.new
  end

  # GET /working_schedules/1/edit
  def edit
  end

  # POST /working_schedules
  # POST /working_schedules.json
  def create
    @working_schedule = WorkingSchedule.new(working_schedule_params)

    respond_to do |format|
      if @working_schedule.save
        format.html { redirect_to @working_schedule, notice: 'Working schedule was successfully created.' }
        format.json { render json: @working_schedule, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @working_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_schedules/1
  # PATCH/PUT /working_schedules/1.json
  def update
    respond_to do |format|
      if @working_schedule.update(working_schedule_params)
        format.html { redirect_to @working_schedule, notice: 'Working schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @working_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_schedules/1
  # DELETE /working_schedules/1.json
  def destroy
    @working_schedule.destroy
    respond_to do |format|
      format.html { redirect_to working_schedules_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_schedule
      @working_schedule = WorkingSchedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_schedule_params
      params.require(:working_schedule).permit(:user_id, :scheduled_day_of_week, :scheduled_date, :start_time, :end_time, :weekly)
    end

    def correct_user
      redirect_to root_path unless current_user.doctor?
    end
end
