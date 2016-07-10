require 'test_helper'

class WorkingSchedulesControllerTest < ActionController::TestCase
  setup do
    @working_schedule = working_schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_schedule" do
    assert_difference('WorkingSchedule.count') do
      post :create, working_schedule: { end_time: @working_schedule.end_time, scheduled_date: @working_schedule.scheduled_date, scheduled_day_of_week: @working_schedule.scheduled_day_of_week, start_time: @working_schedule.start_time, user_id: @working_schedule.user_id, weekly: @working_schedule.weekly }
    end

    assert_redirected_to working_schedule_path(assigns(:working_schedule))
  end

  test "should show working_schedule" do
    get :show, id: @working_schedule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_schedule
    assert_response :success
  end

  test "should update working_schedule" do
    patch :update, id: @working_schedule, working_schedule: { end_time: @working_schedule.end_time, scheduled_date: @working_schedule.scheduled_date, scheduled_day_of_week: @working_schedule.scheduled_day_of_week, start_time: @working_schedule.start_time, user_id: @working_schedule.user_id, weekly: @working_schedule.weekly }
    assert_redirected_to working_schedule_path(assigns(:working_schedule))
  end

  test "should destroy working_schedule" do
    assert_difference('WorkingSchedule.count', -1) do
      delete :destroy, id: @working_schedule
    end

    assert_redirected_to working_schedules_path
  end
end
