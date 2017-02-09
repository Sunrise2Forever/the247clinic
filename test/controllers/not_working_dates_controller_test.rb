require 'test_helper'

class NotWorkingDatesControllerTest < ActionController::TestCase
  setup do
    @not_working_date = not_working_dates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:not_working_dates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create not_working_date" do
    assert_difference('NotWorkingDate.count') do
      post :create, not_working_date: { date: @not_working_date.date, user_id: @not_working_date.user_id }
    end

    assert_redirected_to not_working_date_path(assigns(:not_working_date))
  end

  test "should show not_working_date" do
    get :show, id: @not_working_date
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @not_working_date
    assert_response :success
  end

  test "should update not_working_date" do
    patch :update, id: @not_working_date, not_working_date: { date: @not_working_date.date, user_id: @not_working_date.user_id }
    assert_redirected_to not_working_date_path(assigns(:not_working_date))
  end

  test "should destroy not_working_date" do
    assert_difference('NotWorkingDate.count', -1) do
      delete :destroy, id: @not_working_date
    end

    assert_redirected_to not_working_dates_path
  end
end
