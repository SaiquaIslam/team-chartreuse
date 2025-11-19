class CreateCorpseFlowers < ActiveRecord::Migration[7.1]
  def change
    create_table :corpse_flowers do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :size  # small, medium, large
      t.integer :putridity  # 1-10 scale
      t.string :color
      t.integer :stock, default: 0, null: false

      t.timestamps
    end

    add_index :corpse_flowers, :name
    add_index :corpse_flowers, :price
    add_index :corpse_flowers, :size
    add_index :corpse_flowers, :putridity
  end
end