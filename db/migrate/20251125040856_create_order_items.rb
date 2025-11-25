class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :corpse_flower, null: false, foreign_key: true
      t.integer :quantity
      t.integer :price_cents

      t.timestamps
    end
  end
end
