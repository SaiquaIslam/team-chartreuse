# frozen_string_literal: true

require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users

  setup do
    @user       = users(:regular)
    @other_user = users(:admin) rescue User.where.not(id: @user.id).first || User.create!(
      email: "other_orders_user@example.com",
      password: "password123"
    )
  end

  # Minimal valid Order for controller + view
  # (we'll make the view nil-safe in step 2)
  def create_order_for(user)
    Order.create!(user: user)
  end

  ############################################################
  # AUTHENTICATION
  ############################################################

  test "unauthenticated user is redirected from index" do
    get orders_path
    assert_response :redirect
  end

  test "unauthenticated user is redirected from show" do
    get order_path(12345)
    assert_response :redirect
  end

  ############################################################
  # INDEX
  ############################################################

  test "authenticated user can view their orders index" do
    sign_in @user

    create_order_for(@user)
    create_order_for(@user)

    get orders_path
    assert_response :success
  end

  ############################################################
  # SHOW
  ############################################################

  test "show displays an order belonging to the current user" do
    sign_in @user

    order = create_order_for(@user)

    get order_path(order)
    assert_response :success
  end

  test "show redirects with alert when order is not found" do
    sign_in @user

    get order_path(999_999)

    assert_redirected_to orders_path
    assert_equal "Order not found.", flash[:alert]
  end

  test "show redirects with alert when order belongs to a different user" do
    sign_in @user

    other_order = create_order_for(@other_user)

    get order_path(other_order)

    assert_redirected_to orders_path
    assert_equal "Order not found.", flash[:alert]
  end
end
