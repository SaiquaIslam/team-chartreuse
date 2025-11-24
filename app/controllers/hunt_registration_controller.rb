class HuntRegistrationController < ApplicationController
    def new
    @hunt_registration = HuntRegistration.new
    render :new
  end

def create
  @hunt_registration = HuntRegistration.new(hunt_registration_params)

  if @hunt_registration.save
    flash[:success] = "Registration completed successfully."
    redirect_to new_hunt_registration_path   # Go back to new page
  else
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
      :photo
    )
  end
end
