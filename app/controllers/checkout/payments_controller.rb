require 'ostruct'

module Checkout
  class PaymentsController < ApplicationController

    def new
      # Pre-fill form if data already exists
      @payment = OpenStruct.new(payment_data || {})
    end

    def create
      # Save submitted payment info
      session[:checkout_payment] = payment_params.to_h

      # Redirect to next step (review page)
      redirect_to '/checkout/review'
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
  end
end