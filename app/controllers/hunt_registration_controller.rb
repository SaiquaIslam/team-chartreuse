class HuntRegistrationController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  def index
  @hunt_registrations = HuntRegistration.order(created_at: :desc)
  render :index
end
  def show
    @hunt_registration = HuntRegistration.find(params[:id])
    @order_item        = @hunt_registration.order_item
    @corpse_flower     = @order_item&.corpse_flower
  end

  def new
    @hunt_registration = HuntRegistration.new

    if params[:order_item_id].present?
      @order_item    = OrderItem.find_by(id: params[:order_item_id])
      @corpse_flower = @order_item.corpse_flower
      @hunt_registration.order_item = @order_item
    end

    render :new
  end

  def create
    @hunt_registration = HuntRegistration.new(hunt_registration_params)
    @hunt_registration.user = current_user

    if @hunt_registration.save
      flash[:success] = "Registration completed successfully."
      redirect_to hunt_path
    else
      # rehydrate order_item / flower for re-render
      @order_item    = @hunt_registration.order_item
      @corpse_flower = @order_item&.corpse_flower
      flash.now[:error] = "Unable to save registration."
      render :new_hunt, status: :unprocessable_entity
    end
  end

  private

  def hunt_registration_params
    params.require(:hunt_registration).permit(
      :nickname,
      :location_description,
      :latitude,
      :longitude,
      :instructions,
      :photo,
      :order_item_id
    )
  end
end
