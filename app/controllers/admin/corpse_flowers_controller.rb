class Admin::CorpseFlowersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_corpse_flower, only: [:edit, :update, :destroy, :increase_stock, :decrease_stock]

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


# =========================
  # US18 — EDIT & UPDATE
  # =========================
  def edit
  end

  def update
    if @corpse_flower.update(corpse_flower_params)
      redirect_to admin_corpse_flowers_path, notice: "Flower updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # =========================
  # US19 — DELETE
  # =========================
 def destroy
  if @corpse_flower.destroy
    redirect_to admin_corpse_flowers_path, notice: "Flower deleted successfully."
  else
    redirect_to admin_corpse_flowers_path, alert: @corpse_flower.errors.full_messages.to_sentence
  end
end


  # ===== US20: Manage Stock (M2 PR2) =====
  def increase_stock
    @corpse_flower.increment!(:stock)
    redirect_to admin_corpse_flowers_path, notice: "Stock increased for #{@corpse_flower.name}."
  end

  def decrease_stock
    if @corpse_flower.stock > 0
      @corpse_flower.decrement!(:stock)
      redirect_to admin_corpse_flowers_path, notice: "Stock decreased for #{@corpse_flower.name}."
    else
      redirect_to admin_corpse_flowers_path, alert: "Stock cannot go below 0."
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
