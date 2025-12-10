class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_corpse_flower
  before_action :ensure_user_purchased_flower!, only: [:new, :create]

  # GET /corpse_flowers/:corpse_flower_id/reviews/new
  def new
    # If the user already reviewed this flower, send them back
    existing = current_user.reviews.find_by(corpse_flower: @corpse_flower)
    if existing
      redirect_to @corpse_flower, alert: "You have already reviewed this flower."
    else
      @review = @corpse_flower.reviews.build
    end
  end

  # POST /corpse_flowers/:corpse_flower_id/reviews
  def create
    @review = @corpse_flower.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @corpse_flower, notice: "Thank you for your review!"
    else
      flash.now[:alert] = @review.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_corpse_flower
    @corpse_flower = CorpseFlower.find(params[:corpse_flower_id])
  end

  def ensure_user_purchased_flower!
    unless current_user.purchased_corpse_flower?(@corpse_flower)
      redirect_to @corpse_flower, alert: "You can only review flowers you have purchased."
    end
  end

  def review_params
    params.require(:review).permit(:rating, :title, :comment, :image)
  end
end