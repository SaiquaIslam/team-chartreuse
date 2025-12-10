# frozen_string_literal: true

require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users, :corpse_flowers, :carts, :cart_items

  setup do
    @user = users(:regular)
  end

  # Authentication
  test "redirects unauthenticated users from show" do
    get cart_path
    assert_response :redirect
  end

  # show with existing cart
  test "authenticated user can view existing cart" do
    sign_in @user

    assert_no_difference "Cart.count" do
      get cart_path
      assert_response :success
    end

    cart = Cart.find_by(user: @user)
    assert_not_nil cart
  end

  # show creates cart if none exists
  test "creates a new cart if user has none" do
    Cart.where(user: @user).destroy_all
    sign_in @user
    assert_nil Cart.find_by(user: @user)

    assert_difference "Cart.count", 1 do
      get cart_path
      assert_response :success
    end

    cart = Cart.find_by(user: @user)
    assert_not_nil cart
    assert_equal @user, cart.user
  end

  # show uses @cart_items (includes corpse flowers)
  test "show loads cart_items with corpse flowers included" do
    sign_in @user

    cart = Cart.for_user(@user)
    cart.cart_items.destroy_all

    CartItem.create!(
      cart: cart,
      corpse_flower: corpse_flowers(:titan_arum),
      quantity: 2
    )

    get cart_path
    assert_response :success
    assert_select "body", /Titan Arum/
  end
end
