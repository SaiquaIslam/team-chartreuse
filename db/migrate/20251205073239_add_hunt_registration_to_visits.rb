class AddHuntRegistrationToVisits < ActiveRecord::Migration[7.1]
  def change
    add_reference :visits, :hunt_registration, null: false, foreign_key: true
  end
end
