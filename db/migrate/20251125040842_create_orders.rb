class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_cents
      t.string :status
      t.string :shipping_name
      t.string :shipping_address
      t.string :shipping_city
      t.string :shipping_state
      t.string :shipping_zip
      t.string :shipping_phone

      t.timestamps
    end
  end
end
