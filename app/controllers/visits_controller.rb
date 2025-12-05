# app/controllers/visits_controller.rb
class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @hunt_registration = HuntRegistration.find(params[:hunt_registration_id])
    @visit = Visit.new
  end

  def create
    @hunt_registration = HuntRegistration.find(params[:hunt_registration_id])
    @visit = @hunt_registration.visits.new(visit_params)
    @visit.user = current_user

    if @visit.save
      flash[:success] = "Visit recorded successfully!"
      redirect_to hunt_registration_path(@hunt_registration)
    else
      flash.now[:error] = "Failed to record visit."
      render :new, status: :unprocessable_entity
    end
  end

  def leaderboard
  @leaderboard = User
    .joins(:visits)
    .select("users.id, users.email, COUNT(visits.id) AS visits_count")
    .group("users.id")
    .order("visits_count DESC")
end


  private

  def visit_params
    params.require(:visit).permit(:comment, :photo, :visited_on)
  end
end
