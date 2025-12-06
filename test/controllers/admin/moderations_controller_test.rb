require "test_helper"

class Admin::ModerationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_moderations_index_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_moderations_destroy_url
    assert_response :success
  end
end
