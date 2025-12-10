require "test_helper"

class Admin::ModerationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @regular = users(:regular)
    @flagged_review = reviews(:flagged_review)
    sign_in @admin
  end

  test "admin can access moderation index" do
    get admin_moderations_url
    assert_response :success
    # Optional: assert flagged content appears
    assert_select "h1", /Moderate Content/i
  end

  test "admin can delete flagged review" do
    assert_difference("Review.count", -1) do
      delete admin_moderation_url(@flagged_review)
    end
    assert_redirected_to admin_moderations_url
  end

  test "non-admin cannot access moderation index" do
    sign_out @admin
    sign_in @regular
    

    get admin_moderations_url
    assert_response :redirect
  end

  test "non-admin cannot delete flagged review" do
    sign_out @admin
    sign_in @regular

    assert_no_difference("Review.count") do
      delete admin_moderation_url(@flagged_review)
    end

    assert_response :redirect
  end
end
