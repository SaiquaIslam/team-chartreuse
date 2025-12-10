# frozen_string_literal: true

require "test_helper"
require "securerandom"

class CartTest < ActiveSupport::TestCase
  fixtures :users, :corpse_flowers, :carts, :cart_items

  setup do
    @user = users(:regular)
    @cart = carts(:regular_cart)
    @item = cart_items(:regular_cart_item)
  end

  ############################################################
  # Associations
  ############################################################

  test "belongs_to user" do
    assert_equal @user, @cart.user
  end

  test "has_many cart_items" do
    assert_includes @cart.cart_items, @item
  end

  test "has_many corpse_flowers through cart_items" do
    assert_includes @cart.corpse_flowers, @item.corpse_flower
  end

  ############################################################
  # .for_user class method
  ############################################################

  test ".for_user returns existing cart for user" do
    found = Cart.for_user(@user)
    assert_equal @cart, found
  end

  test ".for_user creates a new cart if none exists" do
    user_without_cart = User.create!(
      email: "no_cart_#{SecureRandom.hex(4)}@example.com",
      password: "password123"
    )

    assert_nil Cart.find_by(user: user_without_cart)

    assert_difference "Cart.count", 1 do
      cart = Cart.for_user(user_without_cart)
      assert_equal user_without_cart, cart.user
    end
  end

  ############################################################
  # Total price calculation
  ############################################################

  test "calculate_total sums price * quantity for all items" do
    expected_total = @item.corpse_flower.price * @item.quantity
    assert_in_delta expected_total, @cart.calculate_total, 0.001
  end

  test "update_total! persists the calculated total_price" do
    @cart.update_total!
    @cart.reload

    assert_in_delta @cart.calculate_total, @cart.total_price, 0.001
  end

  ############################################################
  # total_items
  ############################################################

  test "total_items returns sum of quantities in cart_items" do
    expected_total = @item.quantity
    assert_equal expected_total, @cart.total_items
  end
end
