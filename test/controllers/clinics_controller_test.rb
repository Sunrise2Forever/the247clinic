require 'test_helper'

class ClinicsControllerTest < ActionController::TestCase
  setup do
    @clinic = clinics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clinics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clinic" do
    assert_difference('Clinic.count') do
      post :create, clinic: { name: @clinic.name }
    end

    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should show clinic" do
    get :show, id: @clinic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @clinic
    assert_response :success
  end

  test "should update clinic" do
    patch :update, id: @clinic, clinic: { name: @clinic.name }
    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should destroy clinic" do
    assert_difference('Clinic.count', -1) do
      delete :destroy, id: @clinic
    end

    assert_redirected_to clinics_path
  end
end
