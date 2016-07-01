class TasksController < AuthenticateController
  def show
    @task = Task.find_by(id: params[:id], doctor_id: current_user.id)
    render json: @task
  end

  def create
    @task = Task.new(task_params)
    @task.doctor_id = current_user.id
    if @task.save
      render json: @task
    else
      render json: { error: @task.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def update
    @task = Task.find_by(id: params[:id], doctor_id: current_user.id)
    if @task.update(task_params)
      render json: @task
    else
      render json: { error: @task.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :details, :done)
    end

end
