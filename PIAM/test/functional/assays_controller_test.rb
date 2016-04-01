require 'test_helper'

class AssaysControllerTest < ActionController::TestCase
  setup do
    @assay = assays(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assays)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assay" do
    assert_difference('Assay.count') do
      post :create, :assay => @assay.attributes
    end

    assert_redirected_to assay_path(assigns(:assay))
  end

  test "should show assay" do
    get :show, :id => @assay
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @assay
    assert_response :success
  end

  test "should update assay" do
    put :update, :id => @assay, :assay => @assay.attributes
    assert_redirected_to assay_path(assigns(:assay))
  end

  test "should destroy assay" do
    assert_difference('Assay.count', -1) do
      delete :destroy, :id => @assay
    end

    assert_redirected_to assays_path
  end
end
