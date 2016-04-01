require 'test_helper'

class PrepareReceptorsControllerTest < ActionController::TestCase
  setup do
    @prepare_receptor = prepare_receptors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prepare_receptors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prepare_receptor" do
    assert_difference('PrepareReceptor.count') do
      post :create, :prepare_receptor => @prepare_receptor.attributes
    end

    assert_redirected_to prepare_receptor_path(assigns(:prepare_receptor))
  end

  test "should show prepare_receptor" do
    get :show, :id => @prepare_receptor
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @prepare_receptor
    assert_response :success
  end

  test "should update prepare_receptor" do
    put :update, :id => @prepare_receptor, :prepare_receptor => @prepare_receptor.attributes
    assert_redirected_to prepare_receptor_path(assigns(:prepare_receptor))
  end

  test "should destroy prepare_receptor" do
    assert_difference('PrepareReceptor.count', -1) do
      delete :destroy, :id => @prepare_receptor
    end

    assert_redirected_to prepare_receptors_path
  end
end
