# frozen_string_literal: true

require "test_helper"
require "ostruct"

module Checkout
  class BaseControllerTest < ActiveSupport::TestCase
    ############################################################
    # Helper to get a fresh controller instance
    ############################################################
    def build_controller
      Checkout::BaseController.new
    end

    ############################################################
    # ensure_cart_not_empty
    ############################################################

    test "ensure_cart_not_empty redirects when current_cart is nil" do
      controller = build_controller

      # Stub current_cart to return nil
      controller.define_singleton_method(:current_cart) { nil }

      # Stub corpse_flowers_path so it doesn't hit routing/url_for
      controller.define_singleton_method(:corpse_flowers_path) { "/corpse_flowers" }

      # Capture redirect args instead of using real redirect_to
      redirected_args = nil
      controller.define_singleton_method(:redirect_to) do |*args|
        redirected_args = args
      end

      controller.send(:ensure_cart_not_empty)

      refute_nil redirected_args, "expected redirect_to to be called"
      path, options = redirected_args
      assert_equal "/corpse_flowers", path
      assert_equal "Your cart is empty.", options[:alert]
    end

    test "ensure_cart_not_empty redirects when cart has empty items" do
      controller = build_controller

      empty_cart = OpenStruct.new(items: [])

      controller.define_singleton_method(:current_cart) { empty_cart }
      controller.define_singleton_method(:corpse_flowers_path) { "/corpse_flowers" }

      redirected_args = nil
      controller.define_singleton_method(:redirect_to) do |*args|
        redirected_args = args
      end

      controller.send(:ensure_cart_not_empty)

      refute_nil redirected_args, "expected redirect_to to be called"
      path, options = redirected_args
      assert_equal "/corpse_flowers", path
      assert_equal "Your cart is empty.", options[:alert]
    end

    test "ensure_cart_not_empty does nothing when cart has items" do
      controller = build_controller

      non_empty_cart = OpenStruct.new(items: [1])

      controller.define_singleton_method(:current_cart) { non_empty_cart }
      controller.define_singleton_method(:corpse_flowers_path) { "/corpse_flowers" }

      redirected_args = nil
      controller.define_singleton_method(:redirect_to) do |*args|
        redirected_args = args
      end

      controller.send(:ensure_cart_not_empty)

      assert_nil redirected_args, "expected no redirect when cart has items"
    end

    ############################################################
    # current_cart – memoization branch
    ############################################################

    test "current_cart memoizes Cart.for_user result" do
      controller = build_controller

      # Stub current_user so method can be called
      controller.define_singleton_method(:current_user) { :fake_user }

      original_for_user = Cart.method(:for_user)
      call_count = 0
      fake_cart  = OpenStruct.new(id: 123)

      Cart.define_singleton_method(:for_user) do |user|
        call_count += 1
        fake_cart
      end

      first  = controller.send(:current_cart)
      second = controller.send(:current_cart)

      assert_equal fake_cart, first
      assert_equal fake_cart, second
      assert_equal 1, call_count, "expected Cart.for_user to be called only once"
    ensure
      Cart.define_singleton_method(:for_user) do |user|
        original_for_user.call(user)
      end
    end

    ############################################################
    # shipping_data
    ############################################################

    test "shipping_data returns nil when session has no checkout_shipping" do
      controller = build_controller

      store = {}
      controller.define_singleton_method(:session) { store }

      result = controller.send(:shipping_data)
      assert_nil result
    end

    test "shipping_data returns value from session when present" do
      controller = build_controller

      store = { checkout_shipping: { "shipping_name" => "John" } }
      controller.define_singleton_method(:session) { store }

      result = controller.send(:shipping_data)
      assert_equal({ "shipping_name" => "John" }, result)
    end
  end
end
