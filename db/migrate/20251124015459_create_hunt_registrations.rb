class CreateHuntRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :hunt_registrations do |t|
      t.references :user, null: false, foreign_key: true
      # t.references :order_item, null: false, foreign_key: true
      t.string :nickname
      t.string :location_description
      t.decimal :latitude
      t.decimal :longitude
      t.text :instructions

      t.timestamps
      #add_column :hunt_registrations, :order_item_id, :integer

    end
  end
end
