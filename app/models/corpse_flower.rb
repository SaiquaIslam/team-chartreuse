# == Schema Information
#
# Table name: corpse_flowers
#
#  id          :bigint           not null, primary key
#  color       :string
#  description :text
#  name        :string           not null
#  price       :decimal(10, 2)   not null
#  putridity   :integer
#  size        :string
#  stock       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_corpse_flowers_on_name       (name)
#  index_corpse_flowers_on_price      (price)
#  index_corpse_flowers_on_putridity  (putridity)
#  index_corpse_flowers_on_size       (size)
#
class CorpseFlower < ApplicationRecord
  # Active Storage for multiple images
  has_many_attached :images

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :size, inclusion: { in: %w[small medium large], allow_nil: true }
  validates :putridity, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true

  # Scopes for search functionality (US03)
  scope :search_by_name, ->(query) {
    where("name ILIKE ?", "%#{query}%") if query.present?
  }

  scope :search_by_description, ->(query) {
    where("description ILIKE ?", "%#{query}%") if query.present?
  }

  # Combined search scope
  def self.search(query)
    return all if query.blank?
    
    where("name ILIKE :query OR description ILIKE :query", query: "%#{query}%")
  end

  # Helper methods
  def in_stock?
    stock > 0
  end

  def out_of_stock?
    stock == 0
  end

  def formatted_price
    "$#{price.round(2)}"
  end

  def size_display
    size&.capitalize || "N/A"
  end

  def putridity_display
    putridity ? "#{putridity}/10" : "N/A"
  end

  
def status_badge
  if stock == 0
    "<span class='badge bg-danger'>Sold Out</span>".html_safe
  elsif stock < 5
    "<span class='badge bg-warning text-dark'>Low Stock</span>".html_safe
  else
    "<span class='badge bg-success'>In Stock</span>".html_safe
  end
end



end