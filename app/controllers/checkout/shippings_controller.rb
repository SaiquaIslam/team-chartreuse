require 'ostruct'

module Checkout
  class ShippingsController < ApplicationController
    def new
      @shipping = OpenStruct.new(shipping_data || {})
      @errors   = []  # for displaying validation errors in the view if needed
    end

    def create
      # Build an object from submitted params so we can validate and re-render safely
      @shipping = OpenStruct.new(shipping_params.to_h)
      @errors   = validate_shipping(@shipping)

      if @errors.any?
        # Do NOT go to payment, stay on this page and show errors
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      else
        # Existing behaviour: store in session and continue to payment
        session[:checkout_shipping] = shipping_params.to_h
        redirect_to '/checkout/payment'
      end
    end

    private

    def shipping_params
      params.require(:shipping).permit(
        :shipping_name,
        :shipping_address,
        :shipping_city,
        :shipping_state,
        :shipping_zip,
        :shipping_phone
      )
    end

    def shipping_data
      session[:checkout_shipping]
    end

    # Simple server-side validation without changing the data model
    def validate_shipping(shipping)
      errors = []

      # Presence checks
      errors << "Name can't be blank" if shipping.shipping_name.to_s.strip.empty?
      errors << "Address can't be blank" if shipping.shipping_address.to_s.strip.empty?
      errors << "City can't be blank" if shipping.shipping_city.to_s.strip.empty?
      errors << "State can't be blank" if shipping.shipping_state.to_s.strip.empty?
      errors << "ZIP can't be blank" if shipping.shipping_zip.to_s.strip.empty?
      errors << "Phone can't be blank" if shipping.shipping_phone.to_s.strip.empty?

      # ZIP format (US-style, adjust if needed)
      if shipping.shipping_zip.to_s.strip.present? &&
         !shipping.shipping_zip.to_s.match?(/\A\d{5}(-\d{4})?\z/)
        errors << "ZIP must be a valid ZIP code (e.g. 12345 or 12345-6789)"
      end

      # Phone format (very basic)
      if shipping.shipping_phone.to_s.strip.present? &&
         !shipping.shipping_phone.to_s.match?(/\A\+?[0-9\-\s]{7,}\z/)
        errors << "Phone must be a valid phone number"
      end

      errors
    end
  end
end
