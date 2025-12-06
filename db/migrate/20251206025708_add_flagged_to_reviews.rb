class AddFlaggedToReviews < ActiveRecord::Migration[7.1]
  def change
    add_column :reviews, :flagged, :boolean, default: false
  end
end
