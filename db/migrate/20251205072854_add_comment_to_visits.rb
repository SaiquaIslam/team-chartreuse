class AddCommentToVisits < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :comment, :text
  end
end
