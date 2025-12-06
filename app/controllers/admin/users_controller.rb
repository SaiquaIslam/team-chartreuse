class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: [:suspend, :unsuspend]

  def index
    @users = User.order(:email)
  end

  def suspend
    @user.update!(suspended: true)
    redirect_to admin_users_path, notice: "#{@user.email} has been suspended."
  end

  def unsuspend
    @user.update!(suspended: false)
    redirect_to admin_users_path, notice: "#{@user.email} has been unsuspended."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin!
    redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
  end
end
