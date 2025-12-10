# frozen_string_literal: true

require "test_helper"
require "ostruct"

module Checkout
  class ReviewsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    fixtures :users, :corpse_flowers

    setup do
      @user          = users(:regular)
      @corpse_flower = corpse_flowers(:titan_arum) rescue CorpseFlower.first
    end

    # Helper: post valid shipping to populate session[:checkout_shipping]
    def populate_shipping_session
      post checkout_shipping_path, params: {
        shipping: {
          shipping_name:    "John Doe",
          shipping_address: "123 Main St",
          shipping_city:    "Memphis",
          shipping_state:   "TN",
          shipping_zip:     "38152",
          shipping_phone:   "+1 901-555-1234"
        }
      }
    end

    ############################################################
    # AUTHENTICATION
    ############################################################

    test "unauthenticated user is redirected from show" do
      get checkout_review_path
      assert_response :redirect
    end

    test "unauthenticated user is redirected from create" do
      post checkout_review_path
      assert_response :redirect
    end

    ############################################################
    # SHOW
    ############################################################

    test "show loads for authenticated user with current cart" do
      sign_in @user

      # Ensure user has a cart (even if empty)
      Cart.for_user(@user)

      get checkout_review_path
      assert_response :success
    end

    test "show still works when current_cart rescue returns nil" do
      sign_in @user

      # Monkey-patch Cart.for_user to raise, so current_cart rescues and returns nil
      original_method = Cart.method(:for_user)

      Cart.define_singleton_method(:for_user) do |_user|
        raise "boom"
      end

      get checkout_review_path
      assert_response :success
    ensure
      # Restore original Cart.for_user no matter what
      Cart.define_singleton_method(:for_user) do |user|
        original_method.call(user)
      end
    end

    ############################################################
    # CREATE – cart with items
    ############################################################

    test "create builds order from cart items, clears cart and checkout session" do
      sign_in @user

      # 1) Populate shipping session via shipping controller (realistic flow)
      populate_shipping_session
      assert_not_nil session[:checkout_shipping]

      # 2) Build a cart with items
      cart = Cart.for_user(@user)

      # Two items with different prices/quantities
      flower1 = @corpse_flower
      flower2 = corpse_flowers(:rafflesia) rescue CorpseFlower.where.not(id: flower1.id).first || flower1

      flower1.update!(price: 10.00)
      flower2.update!(price: 20.00)

      # Clean existing cart items so we know exactly how many will be used
      cart.cart_items.destroy_all

      CartItem.create!(cart: cart, corpse_flower: flower1, quantity: 2) # 2 * 10.00
      CartItem.create!(cart: cart, corpse_flower: flower2, quantity: 1) # 1 * 20.00

      cart_item_count = cart.cart_items.count
      # Expected cents: (2 * 10.00 + 1 * 20.00) * 100 = 4000
      expected_total_cents = 4000

      old_order_count      = Order.count
      old_order_item_count = OrderItem.count

      post checkout_review_path

      # One new order created
      assert_equal old_order_count + 1, Order.count
      order = Order.last

      # Number of order_items created should match number of cart_items
      assert_equal old_order_item_count + cart_item_count, OrderItem.count
      assert_equal cart_item_count, order.order_items.count

      # After redirect, checkout session should be cleared
      assert_nil session[:checkout_shipping]
      assert_nil session[:checkout_payment]

      assert_redirected_to checkout_confirmation_path(order)

      # Check order fields
      assert_equal @user, order.user
      assert_equal expected_total_cents, order.total_cents
      assert_equal "paid", order.status

      # Shipping fields copied from session
      assert_equal "John Doe",        order.shipping_name
      assert_equal "123 Main St",     order.shipping_address
      assert_equal "Memphis",         order.shipping_city
      assert_equal "TN",              order.shipping_state
      assert_equal "38152",           order.shipping_zip
      assert_equal "+1 901-555-1234", order.shipping_phone

      # Verify each order_item’s quantity and price_cents
      item1 = order.order_items.find_by(corpse_flower_id: flower1.id)
      item2 = order.order_items.find_by(corpse_flower_id: flower2.id)

      assert_equal 2, item1.quantity
      assert_equal (10.00 * 100).to_i, item1.price_cents

      assert_equal 1, item2.quantity
      assert_equal (20.00 * 100).to_i, item2.price_cents

      # Cart items should be cleared
      assert_equal 0, cart.cart_items.count
    end

    ############################################################
    # CREATE – empty cart
    ############################################################

    test "create creates order with zero total when cart has no items" do
      sign_in @user

      # Populate shipping session so Order.create! has data
      populate_shipping_session

      # Ensure user has an empty cart
      cart = Cart.for_user(@user)
      cart.cart_items.destroy_all

      old_order_count      = Order.count
      old_order_item_count = OrderItem.count

      post checkout_review_path

      order = Order.last
      assert_equal old_order_count + 1, Order.count
      # No new order_items should be created
      assert_equal old_order_item_count, OrderItem.count

      assert_redirected_to checkout_confirmation_path(order)
      assert_equal 0, order.total_cents
      assert_equal "paid", order.status

      # Checkout session should be cleared
      assert_nil session[:checkout_shipping]
      assert_nil session[:checkout_payment]
    end

    ############################################################
    # BRANCH: price_cents_for (corpse_flower & price nil vs present)
    ############################################################

    test "price_cents_for returns 0 when corpse flower or price is nil" do
      controller = Checkout::ReviewsController.new

      # case 1: corpse_flower is nil
      item1 = OpenStruct.new(corpse_flower: nil, quantity: 1)
      result1 = controller.send(:price_cents_for, item1)
      assert_equal 0, result1

      # case 2: corpse_flower present but price nil
      item2 = OpenStruct.new(corpse_flower: OpenStruct.new(price: nil), quantity: 1)
      result2 = controller.send(:price_cents_for, item2)
      assert_equal 0, result2
    end

    test "price_cents_for returns positive cents when price present" do
      controller = Checkout::ReviewsController.new

      item = OpenStruct.new(corpse_flower: OpenStruct.new(price: 12.50), quantity: 1)
      result = controller.send(:price_cents_for, item)

      assert_equal 1250, result
    end

    ############################################################
    # BRANCH: update_cart_total (respond_to? true vs false)
    ############################################################

    test "update_cart_total calls update_total! when cart responds to it" do
      controller = Checkout::ReviewsController.new

      cart = OpenStruct.new
      called = false
      cart.define_singleton_method(:update_total!) { called = true }

      controller.send(:update_cart_total, cart)
      assert_equal true, called
    end

    test "update_cart_total does nothing when cart does not respond to update_total!" do
      controller = Checkout::ReviewsController.new
      cart = OpenStruct.new # no update_total! method

      # Should not raise or do anything – just hit the false branch
      controller.send(:update_cart_total, cart)
    end

    ############################################################
    # BRANCH: current_cart (current_user nil vs present)
    ############################################################

    test "current_cart returns nil when there is no current_user" do
      controller = Checkout::ReviewsController.new

      # Stub current_user on this controller instance to return nil
      controller.define_singleton_method(:current_user) { nil }

      result = controller.send(:current_cart)
      assert_nil result
    end
  end
end
