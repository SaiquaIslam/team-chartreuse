require 'ostruct'

module Checkout
  class ShippingsController < ApplicationController
    def new
      @shipping = OpenStruct.new(shipping_data || {})
    end

    def create
      session[:checkout_shipping] = shipping_params.to_h
      redirect_to '/checkout/payment'
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
  end
end
