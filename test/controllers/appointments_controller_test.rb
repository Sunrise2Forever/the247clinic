require 'test_helper'

class AppointmentsControllerTest < ActionController::TestCase
  setup do
    @appointment = appointments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:appointments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create appointment" do
    assert_difference('Appointment.count') do
      post :create, appointment: { clinic_id: @appointment.clinic_id, doctor_id: 
                      @appointment.doctor_id, email: @appointment.email, phone: @appointment.phone} 
                      #scheduled_time: @appointment.scheduled_time, status: @appointment.status, user_id: @appointment.user_id }
    end

    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test "should show appointment" do
    get :show, id: @appointment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @appointment
    assert_response :success
  end

  test "should update appointment" do
    patch :update, id: @appointment, appointment: { clinic_id: @appointment.clinic_id, doctor_id: @appointment.doctor_id, email: @appointment.email, 
    phone: @appointment.phone} 
    #scheduled_time: @appointment.scheduled_time, status: @appointment.status, user_id: @appointment.user_id }
    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test "should destroy appointment" do
    assert_difference('Appointment.count', -1) do
      delete :destroy, id: @appointment
    end

    assert_redirected_to appointments_path
  end
end
