# frozen_string_literal: true

require "test_helper"

module Checkout
  class ShippingsControllerTest < ActionDispatch::IntegrationTest
    # Helper: valid base params to tweak per test
    def valid_shipping_params(overrides = {})
      {
        shipping_name:    "John Doe",
        shipping_address: "123 Main St",
        shipping_city:    "Memphis",
        shipping_state:   "TN",
        shipping_zip:     "38152",
        shipping_phone:   "+1 901-555-1234"
      }.merge(overrides)
    end

    ############################################################
    # NEW
    ############################################################

    test "new loads successfully" do
      get checkout_shipping_path
      assert_response :success
    end

    ############################################################
    # CREATE – INVALID: presence errors
    ############################################################

    test "create with all blank fields re-renders new with errors" do
      post checkout_shipping_path, params: {
        shipping: {
          shipping_name:    "",
          shipping_address: "",
          shipping_city:    "",
          shipping_state:   "",
          shipping_zip:     "",
          shipping_phone:   ""
        }
      }

      assert_response :unprocessable_entity
      assert_equal "Please fix the errors below.", flash[:alert]
      # Should not store anything in the session
      assert_nil session[:checkout_shipping]
    end

    ############################################################
    # CREATE – INVALID: ZIP format
    ############################################################

    test "create with invalid ZIP re-renders new with errors" do
      post checkout_shipping_path, params: {
        shipping: valid_shipping_params(shipping_zip: "ABC123")
      }

      assert_response :unprocessable_entity
      assert_equal "Please fix the errors below.", flash[:alert]
      assert_nil session[:checkout_shipping]
    end

    ############################################################
    # CREATE – INVALID: phone format
    ############################################################

    test "create with invalid phone re-renders new with errors" do
      post checkout_shipping_path, params: {
        shipping: valid_shipping_params(shipping_phone: "not-a-phone")
      }

      assert_response :unprocessable_entity
      assert_equal "Please fix the errors below.", flash[:alert]
      assert_nil session[:checkout_shipping]
    end

    ############################################################
    # CREATE – VALID
    ############################################################

    test "create with valid data stores shipping in session and redirects to payment" do
      params_hash = valid_shipping_params

      post checkout_shipping_path, params: { shipping: params_hash }

      assert_redirected_to "/checkout/payment"

      # shipping_params.to_h will give string keys, so compare stringified
      expected = params_hash.stringify_keys
      assert_equal expected, session[:checkout_shipping]
    end
  end
end
