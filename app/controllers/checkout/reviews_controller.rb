# app/controllers/checkout/reviews_controller.rb
module Checkout
  class ReviewsController < ApplicationController
    before_action :authenticate_user!

    def show
      @shipping = session[:checkout_shipping] || {}
      @payment  = session[:checkout_payment] || {}
      @cart     = current_cart
    end

    def create
      @shipping = session[:checkout_shipping] || {}
      @cart     = current_cart

      # 1) compute total from cart (if any)
      total_cents = 0
      if @cart && @cart.respond_to?(:cart_items) && @cart.cart_items.any?
        total_cents = @cart.cart_items.sum do |item|
          price       = item.corpse_flower&.price || 0
          price_cents = (price.to_f * 100).to_i
          price_cents * item.quantity
        end
      end

      # 2) create the order
      @order = Order.create!(
        user:             current_user,
        total_cents:      total_cents,
        status:           "paid",
        shipping_name:    @shipping["shipping_name"],
        shipping_address: @shipping["shipping_address"],
        shipping_city:    @shipping["shipping_city"],
        shipping_state:   @shipping["shipping_state"],
        shipping_zip:     @shipping["shipping_zip"],
        shipping_phone:   @shipping["shipping_phone"]
      )

      # 3) create order_items from the cart
      if @cart && @cart.respond_to?(:cart_items) && @cart.cart_items.any?
        @cart.cart_items.each do |item|
          price       = item.corpse_flower&.price || 0
          price_cents = (price.to_f * 100).to_i

          @order.order_items.create!(
            corpse_flower: item.corpse_flower,
            quantity:      item.quantity,
            price_cents:   price_cents
          )
        end

        # clear cart after order
        @cart.cart_items.destroy_all
        @cart.update_total! if @cart.respond_to?(:update_total!)
      end

      # 4) clear checkout session
      session.delete(:checkout_shipping)
      session.delete(:checkout_payment)

      # 5) go to confirmation page
      redirect_to checkout_confirmation_path(@order)
    end

    private

    def current_cart
      return nil unless current_user
      Cart.for_user(current_user)
    rescue
      nil
    end
  end
end

