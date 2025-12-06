class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  # M1 PR3 - US06 Add Item
  def create
    @corpse_flower = CorpseFlower.find(params[:corpse_flower_id])
    
    # Check if item already in cart
    @cart_item = @cart.cart_items.find_by(corpse_flower_id: @corpse_flower.id)
    
    if @cart_item
      # If already exists, increase quantity
      @cart_item.quantity += 1
      @cart_item.save
    else
      # Create new cart item
      @cart_item = @cart.cart_items.create(
        corpse_flower: @corpse_flower,
        quantity: 1
      )
    end
    
    # Update cart total
    @cart.update_total!
    
    redirect_to corpse_flower_path(@corpse_flower), notice: "#{@corpse_flower.name} added to cart!"
  end

  # M2 PR3 - US09 Update Quantity
  def update
    new_quantity = params[:quantity].to_i
    
    # Edge case: if quantity is 0 or less, remove the item
    if new_quantity <= 0
      @cart_item.destroy
      @cart.update_total!
      redirect_to cart_path, notice: "Item removed from cart."
      return
    end
    
    # Validate quantity doesn't exceed stock
    if new_quantity > @cart_item.corpse_flower.stock
      redirect_to cart_path, alert: "Only #{@cart_item.corpse_flower.stock} available in stock."
      return
    end
    
    # Update quantity
    @cart_item.update(quantity: new_quantity)
    @cart.update_total!
    
    redirect_to cart_path, notice: "Quantity updated."
  end

  # M2 PR3 - US08 Remove Item
  def destroy
    flower_name = @cart_item.corpse_flower.name
    @cart_item.destroy
    @cart.update_total!
    
    redirect_to cart_path, notice: "#{flower_name} removed from cart."
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Item not found in cart."
  end
end