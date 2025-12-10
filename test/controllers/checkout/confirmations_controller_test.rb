# frozen_string_literal: true

require "test_helper"

module Checkout
  class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    fixtures :users

    def create_order_for(user, total_cents: 1500, status: "paid")
      Order.create!(
        user:        user,
        total_cents: total_cents,
        status:      status
      )
    end

    ############################################################
    # Authentication
    ############################################################

    test "unauthenticated user is redirected from confirmation show" do
      user  = users(:regular)
      order = create_order_for(user)

      get checkout_confirmation_path(order)
      assert_response :redirect
    end

    ############################################################
    # Show – success
    ############################################################

    test "authenticated user can view confirmation for their own order" do
      user  = users(:regular)
      order = create_order_for(user)

      sign_in user
      get checkout_confirmation_path(order)

      assert_response :success
      # This executes: @order = current_user.orders.find(params[:id])
    end

    ############################################################
    # Show – order does NOT belong to current user
    ############################################################

    test "returns 404 when user tries to view another user's order" do
      owner    = users(:regular)
      stranger = users(:admin) rescue users(:regular)

      # Need two distinct users for this test
      skip "Need at least two distinct users in fixtures for this test" if owner.id == stranger.id

      foreign_order = create_order_for(owner)

      sign_in stranger
      get checkout_confirmation_path(foreign_order)

      # In integration tests, RecordNotFound becomes a 404
      assert_response :not_found
    end
  end
end
