class AddVisitedOnToVisits < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :visited_on, :date
  end
end
