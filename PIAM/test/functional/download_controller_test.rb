require 'test_helper'

class DownloadControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get notification" do
    get :notification
    assert_response :success
  end

end
