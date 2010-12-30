require 'test_helper'

class ContentControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
