class Admin::CorpseFlowersController < ApplicationController
  # later add auth/authorization here

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

  def edit
    @corpse_flower = CorpseFlower.find(params[:id])
  end

  def update
    @corpse_flower = CorpseFlower.find(params[:id])

    if @corpse_flower.update(corpse_flower_params)
      redirect_to admin_corpse_flowers_path, notice: "Flower updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

def destroy
  @corpse_flower = CorpseFlower.find(params[:id])
  @corpse_flower.destroy

  redirect_to admin_corpse_flowers_path, notice: "Flower removed successfully."
end



def increase_stock
  @corpse_flower = CorpseFlower.find(params[:id])
  @corpse_flower.stock += 1
  @corpse_flower.save

  redirect_to admin_corpse_flowers_path, notice: "Stock increased."
end

def decrease_stock
  @corpse_flower = CorpseFlower.find(params[:id])

  if @corpse_flower.stock > 0
    @corpse_flower.stock -= 1
    @corpse_flower.save
  end

  redirect_to admin_corpse_flowers_path, notice: "Stock updated."
end


  private

  def corpse_flower_params
    params.require(:corpse_flower).permit(
      :name, :description, :price, :stock, :size, :color, :putridity,
       images: [] 
    )
  end
end
