require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin     = users(:admin)
    @regular   = users(:regular)
    @suspended = users(:suspended)
  end

  # === INDEX ACTION ===

  test "admin can view users index" do
    sign_in @admin

    get admin_users_path
    assert_response :success
  end

  test "non-admin cannot view users index" do
    sign_in @regular

    get admin_users_path
    assert_redirected_to root_path
    assert_equal "Unauthorized", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    # no sign_in here on purpose
    get admin_users_path

    assert_redirected_to new_user_session_path
  end

  # === SUSPEND ACTION ===

  test "admin can suspend a regular user" do
    sign_in @admin
    assert_not @regular.suspended

    patch suspend_admin_user_path(@regular)

    assert_redirected_to admin_users_path
    @regular.reload
    assert @regular.suspended
  end

  test "non-admin cannot suspend a user" do
    sign_in @regular

    patch suspend_admin_user_path(@suspended)

    assert_redirected_to root_path
    assert_equal "Unauthorized", flash[:alert]
    @suspended.reload
    assert @suspended.suspended  # state unchanged
  end

  # === UNSUSPEND ACTION ===

  test "admin can unsuspend a suspended user" do
    sign_in @admin
    assert @suspended.suspended

    patch unsuspend_admin_user_path(@suspended)

    assert_redirected_to admin_users_path
    @suspended.reload
    assert_not @suspended.suspended
  end

  test "non-admin cannot unsuspend a user" do
    sign_in @regular

    patch unsuspend_admin_user_path(@suspended)

    assert_redirected_to root_path
    assert_equal "Unauthorized", flash[:alert]
  end
end
