class HuntRegistrationController < ApplicationController
    before_action :authenticate_user!

      # US25 – Browse all registered hunt flowers
  def index
    @hunt_registrations = HuntRegistration.order(created_at: :desc)
    render :index
  end
  def show
  @hunt_registration = HuntRegistration.find(params[:id])
  render :show
end
    def new
    @hunt_registration = HuntRegistration.new
    render :new
  end

def create
  @hunt_registration = HuntRegistration.new(hunt_registration_params)
  @hunt_registration.user = current_user

  if @hunt_registration.save
    flash[:success] = "Registration completed successfully."
    redirect_to hunt_path
  else
    flash.now[:error] = "Unable to save registration."
    render :new, status: :unprocessable_entity
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
      :photo
    )
  end
end
