class HuntRegistrationController < ApplicationController
before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
before_action :set_hunt_registration, only: [:show, :edit, :update, :destroy, :confirm_remove]
before_action :authorize_owner!, only: [:edit, :update, :destroy, :confirm_remove]

def index
  if params[:query].present?
    q = "%#{params[:query]}%"
    @hunt_registrations = HuntRegistration
      .left_joins(:user)
      .where("hunt_registrations.nickname ILIKE ?
              OR hunt_registrations.location_description ILIKE ?
              OR users.email ILIKE ?",
              q, q, q)
      .order(created_at: :desc)
  else
    @hunt_registrations = HuntRegistration.order(created_at: :desc)
  end
end

  def show
    @hunt_registration = HuntRegistration.find(params[:id])
    @order_item        = @hunt_registration.order_item
    @corpse_flower     = @order_item&.corpse_flower
    @visits = @hunt_registration.visits.includes(:user, photo_attachment: :blob).order(created_at: :desc)

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

  def edit
    @hunt_registration = HuntRegistration.find(params[:id])
  end

def update
  @hunt_registration = HuntRegistration.find(params[:id])
  if @hunt_registration.update(hunt_registration_params)
    flash[:success] = "Hunt registration updated successfully."
    redirect_to hunt_registration_path(@hunt_registration)
  else
    flash.now[:error] = "Unable to update hunt registration."
    render :edit, status: :unprocessable_entity
  end
end

def confirm_remove
  @hunt_registration = HuntRegistration.find(params[:id])
  render :remove
end

def destroy
  @hunt_registration = HuntRegistration.find(params[:id])
  @hunt_registration.destroy

  flash[:success] = 'Flower was removed from the scavenger hunt.'
  redirect_to hunt_path 
end


  private

  def set_hunt_registration
    @hunt_registration = HuntRegistration.find(params[:id])
  end

  def authorize_owner!
    return if @hunt_registration.user == current_user

    flash[:alert] = "You are not authorized to modify this hunt registration."
    redirect_to hunt_registration_path(@hunt_registration)
  end



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
