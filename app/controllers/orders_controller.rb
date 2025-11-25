class OrdersController < ApplicationController
  before_action :authenticate_user!

  # GET /orders
  # Rafy PR3 – Purchase history list (US13)
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  # GET /orders/:id
  # Rafy PR3 – Purchase history detail page (US13)
  def show
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end
end
