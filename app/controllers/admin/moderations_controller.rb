class Admin::ModerationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @flagged_reviews = Review.where(flagged: true).order(created_at: :desc)
  end

  def destroy
    review = Review.find(params[:id])
    review.destroy
    redirect_to admin_moderations_path, notice: "Review deleted successfully."
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user.admin?
  end
end
