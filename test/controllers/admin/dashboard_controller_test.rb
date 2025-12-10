require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @regular = users(:regular)
  end

  test "admin should get index" do
    sign_in @admin
    get admin_dashboard_url
    assert_response :success

    # Assuming you render some summary info:
    assert_select "h1", /Dashboard/i
  end

  test "non-admin should be redirected from dashboard" do
    sign_in @regular
    get admin_dashboard_url
    assert_response :redirect
  end
end
