class AddOrderItemToHuntRegistrations < ActiveRecord::Migration[7.1]
  def change
    add_reference :hunt_registrations, :order_item, foreign_key: true

  end
end
