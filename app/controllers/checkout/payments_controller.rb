require 'ostruct'

module Checkout
  class PaymentsController < ApplicationController

    def new
      # Pre-fill form if data already exists
      @payment = OpenStruct.new(payment_data || {})
      @errors  = []  # for displaying validation errors in the view if needed
    end

    def create
      # Build an object from submitted params so we can validate and re-render safely
      @payment = OpenStruct.new(payment_params.to_h)
      @errors  = validate_payment(@payment)

      if @errors.any?
        # Stay on this page and show errors, do NOT go to review
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      else
        # Existing behaviour: store in session and continue to review step
        session[:checkout_payment] = payment_params.to_h
        redirect_to '/checkout/review'
      end
    end

    private

    def payment_params
      params.require(:payment).permit(
        :card_number,
        :expiry_month,
        :expiry_year,
        :cvv,
        :billing_zip
      )
    end

    def payment_data
      session[:checkout_payment]
    end

    # Simple server-side validation for payment step
    def validate_payment(payment)
      errors = []

      # Presence checks
      errors << "Card number can't be blank" if payment.card_number.to_s.strip.empty?
      errors << "Expiry month can't be blank" if payment.expiry_month.to_s.strip.empty?
      errors << "Expiry year can't be blank"  if payment.expiry_year.to_s.strip.empty?
      errors << "CVV can't be blank"         if payment.cvv.to_s.strip.empty?
      errors << "Billing ZIP can't be blank" if payment.billing_zip.to_s.strip.empty?

      # Card number: basic 16-digit check
      if payment.card_number.to_s.strip.present? &&
         !payment.card_number.to_s.match?(/\A\d{16}\z/)
        errors << "Card number must be 16 digits"
      end

      # Expiry month: 1–12
      if payment.expiry_month.to_s.strip.present?
        month = payment.expiry_month.to_i
        unless month.between?(1, 12)
          errors << "Expiry month must be between 1 and 12"
        end
      end

      # Expiry year: simple numeric check (you can tighten this if needed)
      if payment.expiry_year.to_s.strip.present? &&
         !payment.expiry_year.to_s.match?(/\A\d{2,4}\z/)
        errors << "Expiry year must be a valid year"
      end

      # CVV: 3–4 digits
      if payment.cvv.to_s.strip.present? &&
         !payment.cvv.to_s.match?(/\A\d{3,4}\z/)
        errors << "CVV must be 3 or 4 digits"
      end

      # Billing ZIP: US-style ZIP format
      if payment.billing_zip.to_s.strip.present? &&
         !payment.billing_zip.to_s.match?(/\A\d{5}(-\d{4})?\z/)
        errors << "Billing ZIP must be a valid ZIP code (e.g. 12345 or 12345-6789)"
      end

      errors
    end
  end
end
