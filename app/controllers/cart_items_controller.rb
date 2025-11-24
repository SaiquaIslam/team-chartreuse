class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @corpse_flower = CorpseFlower.find(params[:corpse_flower_id])
    
    # Find or create cart for current user
    @cart = current_user.cart || current_user.create_cart
    
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
end