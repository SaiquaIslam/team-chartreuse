class CorpseFlowersController < ApplicationController
  before_action :set_corpse_flower, only: [:show]

  # US01: Browse Listings
  # US03: Search Listings
  def index
    @corpse_flowers = CorpseFlower.all

    # Handle search query from navbar (US03)
    if params[:search].present?
      @corpse_flowers = @corpse_flowers.search(params[:search])
    end

    # Order by newest first by default
    @corpse_flowers = @corpse_flowers.order(created_at: :desc)
  end

  # US02: View Details
  def show
    # @corpse_flower is set by before_action
  end

  private

  def set_corpse_flower
    @corpse_flower = CorpseFlower.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to corpse_flowers_path, alert: "Corpse flower not found."
  end
end