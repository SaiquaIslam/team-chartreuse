module Checkout
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_cart_not_empty

    private

    def ensure_cart_not_empty
      if current_cart.blank? || current_cart.items.empty?
        redirect_to corpse_flowers_path, alert: "Your cart is empty."
      end
    end

    def current_cart
      # Adjust to your app's logic, based on your model diagram
      @current_cart ||= Cart.for_user(current_user)
    end

    def shipping_data
      session[:checkout_shipping]
    end
  end
end