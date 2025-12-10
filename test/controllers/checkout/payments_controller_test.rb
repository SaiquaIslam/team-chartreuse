# frozen_string_literal: true

require "test_helper"
require "ostruct"

module Checkout
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    # No auth for this controller

    def valid_payment_params
      {
        card_number: "1234567812345678",
        expiry_month: "12",
        expiry_year:  "27",
        cvv:          "123",
        billing_zip:  "38152"
      }
    end

    ############################################################
    # new
    ############################################################

    test "new renders successfully with no existing payment data" do
      get checkout_payment_path
      assert_response :success
      # hits branch where payment_data is nil
    end

    test "new pre-fills payment from session when data is present" do
    # First, simulate a valid create to populate session[:checkout_payment]
    post checkout_payment_path, params: { payment: valid_payment_params }
    assert_redirected_to "/checkout/review"
    assert_equal valid_payment_params.stringify_keys, session[:checkout_payment]

    # Now hit new – this should read from session via payment_data
    get checkout_payment_path
    assert_response :success
    end


    ############################################################
    # create – invalid: blanks
    ############################################################

    test "create re-renders new with errors when payment fields are blank" do
      post checkout_payment_path, params: {
        payment: {
          card_number: "",
          expiry_month: "",
          expiry_year: "",
          cvv: "",
          billing_zip: ""
        }
      }

      assert_response :unprocessable_entity
      assert_equal "Please fix the errors below.", flash[:alert]
      # hits @errors.any? == true and all the presence checks
    end

    ############################################################
    # create – invalid: bad formats
    ############################################################

    test "create re-renders new with errors when payment formats are invalid" do
      post checkout_payment_path, params: {
        payment: {
          card_number: "abcd",   # not 16 digits
          expiry_month: "13",    # invalid month
          expiry_year:  "yy",    # not numeric year
          cvv:          "1",     # too short
          billing_zip:  "abc"    # invalid zip
        }
      }

      assert_response :unprocessable_entity
      assert_equal "Please fix the errors below.", flash[:alert]
      # hits branches where present? is true but regex / range checks fail
    end

    ############################################################
    # create – valid
    ############################################################

    test "create stores payment in session and redirects when payment is valid" do
      post checkout_payment_path, params: { payment: valid_payment_params }

      assert_redirected_to "/checkout/review"
      assert_equal valid_payment_params.stringify_keys, session[:checkout_payment]
      # hits @errors.any? == false branch
    end

    ############################################################
    # validate_payment – direct branch coverage
    ############################################################

    test "validate_payment returns errors for blank and invalid payment and none for valid payment" do
      controller = Checkout::PaymentsController.new

      # Case 1: all blank -> presence errors
      blank = OpenStruct.new(
        card_number: "",
        expiry_month: "",
        expiry_year: "",
        cvv: "",
        billing_zip: ""
      )
      errors_blank = controller.send(:validate_payment, blank)
      assert errors_blank.any?

      # Case 2: present but invalid formats -> format errors
      invalid = OpenStruct.new(
        card_number: "abcd",
        expiry_month: "13",
        expiry_year: "yy",
        cvv: "12",
        billing_zip: "abc"
      )
      errors_invalid = controller.send(:validate_payment, invalid)

      assert_includes errors_invalid, "Card number must be 16 digits"
      assert_includes errors_invalid, "Expiry month must be between 1 and 12"
      assert_includes errors_invalid, "Expiry year must be a valid year"
      assert_includes errors_invalid, "CVV must be 3 or 4 digits"
      assert_includes errors_invalid, "Billing ZIP must be a valid ZIP code (e.g. 12345 or 12345-6789)"

      # Case 3: everything valid -> no errors
      valid = OpenStruct.new(
        card_number: "1234567812345678",
        expiry_month: "11",
        expiry_year:  "2027",
        cvv:          "999",
        billing_zip:  "12345"
      )
      errors_valid = controller.send(:validate_payment, valid)
      assert_equal 0, errors_valid.size
    end
  end
end
