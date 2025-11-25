class Admin::CorpseFlowersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_corpse_flower, only: []

  def index
    @corpse_flowers = CorpseFlower.order(created_at: :desc)
  end

  def new
    @corpse_flower = CorpseFlower.new
  end

  def create
    @corpse_flower = CorpseFlower.new(corpse_flower_params)
    if @corpse_flower.save
      redirect_to admin_corpse_flowers_path, notice: "Flower created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_corpse_flower
    @corpse_flower = CorpseFlower.find(params[:id])
  end

  def require_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end


def corpse_flower_params
  params.require(:corpse_flower).permit(
    :name, :description, :price, :size, :color,
    :putridity, :stock,
    images: []
  )
  end
end
