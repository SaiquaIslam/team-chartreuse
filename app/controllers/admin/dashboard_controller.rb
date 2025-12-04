class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @total_flowers = CorpseFlower.count
    @total_users   = User.count
    @total_orders  = Order.count
    @total_hunts   = HuntRegistration.count
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user.admin?
  end
end
