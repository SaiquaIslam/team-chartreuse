class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :corpse_flower, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
