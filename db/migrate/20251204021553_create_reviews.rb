class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false
      t.string :title, null: false
      t.text :comment, null: false
      t.string :photo
      t.references :user, null: false, foreign_key: true
      t.references :corpse_flower, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reviews, [:user_id, :corpse_flower_id], unique: true
  end
end