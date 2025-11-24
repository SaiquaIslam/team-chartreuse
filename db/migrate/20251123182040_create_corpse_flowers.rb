class CreateCorpseFlowers < ActiveRecord::Migration[7.1]
  def change
    create_table :corpse_flowers do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :size
      t.string :color
      t.string :putridity
      t.integer :stock, default: 0, null: false
      t.string :status, default: 'available'
      t.string :image_url

      t.timestamps
    end
    
    add_index :corpse_flowers, :name
    add_index :corpse_flowers, :status
  end
end