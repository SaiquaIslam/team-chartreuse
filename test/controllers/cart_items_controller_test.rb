# frozen_string_literal: true

require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users, :corpse_flowers, :carts, :cart_items

  setup do
    @user           = users(:regular)
    @cart           = carts(:regular_cart)
    @existing_item  = cart_items(:regular_cart_item)     # titan_arum, qty 2
    @existing_flower = @existing_item.corpse_flower      # titan_arum
    @other_flower   = corpse_flowers(:small_purple)      # NOT in cart yet
  end

  ############################################################
  # AUTHENTICATION
  ############################################################

  test "redirects unauthenticated user on create" do
    post cart_items_path, params: { corpse_flower_id: @existing_flower.id }
    assert_response :redirect
  end

  test "redirects unauthenticated user on update" do
    patch cart_item_path(@existing_item), params: { quantity: 3 }
    assert_response :redirect
  end

  test "redirects unauthenticated user on destroy" do
    delete cart_item_path(@existing_item)
    assert_response :redirect
  end

  ############################################################
  # CREATE — Add Item
  ############################################################

  test "create adds NEW item when flower not yet in cart" do
    sign_in @user

    existing_total = @cart.calculate_total
    expected_total = existing_total + @other_flower.price

    assert_difference "CartItem.count", 1 do
      post cart_items_path, params: { corpse_flower_id: @other_flower.id }
      assert_response :redirect
    end

    assert_redirected_to corpse_flower_path(@other_flower)
    assert_equal "#{@other_flower.name} added to cart!", flash[:notice]

    @cart.reload
    assert_in_delta expected_total, @cart.total_price, 0.01
  end

  test "create increments quantity when item ALREADY in cart" do
    sign_in @user

    existing_total = @cart.calculate_total
    expected_total = existing_total + @existing_flower.price

    assert_no_difference "CartItem.count" do
      post cart_items_path, params: { corpse_flower_id: @existing_flower.id }
      assert_response :redirect
    end

    @existing_item.reload
    assert_equal 3, @existing_item.quantity   # was 2, now 3

    @cart.reload
    assert_in_delta expected_total, @cart.total_price, 0.01
  end

  ############################################################
  # UPDATE — Change Quantity
  ############################################################

  test "update changes quantity when valid" do
    sign_in @user

    new_quantity = 4
    expected_total = @existing_flower.price * new_quantity

    patch cart_item_path(@existing_item), params: { quantity: new_quantity }
    assert_redirected_to cart_path
    assert_equal "Quantity updated.", flash[:notice]

    @existing_item.reload
    assert_equal new_quantity, @existing_item.quantity

    @cart.reload
    assert_in_delta expected_total, @cart.total_price, 0.01
  end

  test "update with zero quantity removes the cart item" do
    sign_in @user

    assert_difference "CartItem.count", -1 do
      patch cart_item_path(@existing_item), params: { quantity: 0 }
      assert_redirected_to cart_path
    end

    assert_equal "Item removed from cart.", flash[:notice]
  end

  test "update rejects quantity greater than stock" do
    sign_in @user

    @existing_flower.reload
    too_much = @existing_flower.stock + 10
    previous_quantity = @existing_item.quantity

    patch cart_item_path(@existing_item), params: { quantity: too_much }
    assert_redirected_to cart_path
    assert_equal "Only #{@existing_flower.stock} available in stock.", flash[:alert]

    @existing_item.reload
    assert_equal previous_quantity, @existing_item.quantity
  end

  test "update gracefully handles missing cart_item (rescue)" do
    sign_in @user

    patch cart_item_path(id: 999_999), params: { quantity: 3 }
    assert_redirected_to cart_path
    assert_equal "Item not found in cart.", flash[:alert]
  end

  ############################################################
  # DESTROY — Remove Item
  ############################################################

  test "destroy removes item and updates total" do
    sign_in @user

    existing_total = @cart.calculate_total
    expected_total = existing_total - (@existing_flower.price * @existing_item.quantity)

    assert_difference "CartItem.count", -1 do
      delete cart_item_path(@existing_item)
      assert_redirected_to cart_path
    end

    assert_equal "#{@existing_flower.name} removed from cart.", flash[:notice]

    @cart.reload
    assert_in_delta expected_total, @cart.total_price, 0.01
  end

  test "destroy handles missing item (rescue)" do
    sign_in @user

    assert_no_difference "CartItem.count" do
      delete cart_item_path(id: 999_999)
      assert_redirected_to cart_path
    end

    assert_equal "Item not found in cart.", flash[:alert]
  end
end
