require 'test_helper'

class ApsControllerTest < ActionController::TestCase
  setup do
    @ap = aps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:aps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ap" do
    assert_difference('Ap.count') do
      post :create, ap: {  }
    end

    assert_redirected_to ap_path(assigns(:ap))
  end

  test "should show ap" do
    get :show, id: @ap
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ap
    assert_response :success
  end

  test "should update ap" do
    patch :update, id: @ap, ap: {  }
    assert_redirected_to ap_path(assigns(:ap))
  end

  test "should destroy ap" do
    assert_difference('Ap.count', -1) do
      delete :destroy, id: @ap
    end

    assert_redirected_to aps_path
  end
end
