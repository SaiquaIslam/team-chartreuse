module Checkout
  class ConfirmationsController < ApplicationController
    before_action :authenticate_user!

    def show
      @order = current_user.orders.find(params[:id])
    end
  end
end
