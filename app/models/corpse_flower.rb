# frozen_string_literal: true

# == Schema Information
#
# Table name: corpse_flowers
#
#  id          :bigint           not null, primary key
#  color       :string
#  description :text
#  image_url   :string
#  name        :string           not null
#  price       :decimal(10, 2)   not null
#  putridity   :integer
#  size        :string
#  status      :string           default("available")
#  stock       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_corpse_flowers_on_name    (name)
#  index_corpse_flowers_on_status  (status)
#
class CorpseFlower < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available sold_out] }
  validates :size, presence: true, inclusion: { in: %w[small medium large] }
  validates :putridity, presence: true, numericality: { only_integer: true, in: 1..10 }

  # Associations (Tanvir PR3)
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items
  has_many_attached :images
  has_many :reviews, dependent: :destroy

  # Associations (Rafy)
  has_many :order_items
  has_many :orders, through: :order_items
  
  # ========================================
  # SCOPES (M1 + M2)
  # ========================================
  
  # M1 Scopes
  scope :available, -> { where(status: 'available') }
  scope :in_stock, -> { where('stock > ?', 0) }
  scope :search, ->(term) {
    where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", 
          "%#{term.downcase}%", "%#{term.downcase}%") if term.present?
  }
  
  # M2 PR1 - Filter Scopes (US04)
  scope :filter_by_size, ->(sizes) {
    where(size: sizes) if sizes.present?
  }
  
  scope :filter_by_color, ->(colors) {
    where(color: colors) if colors.present?
  }
  
  scope :filter_by_putridity, ->(levels) {
    where(putridity: levels) if levels.present?
  }
  
  # ========================================
  # CLASS METHODS (M2 PR1)
  # ========================================
  
  # Get distinct colors from database for dynamic filter options
  def self.distinct_colors
    distinct.pluck(:color).compact.sort
  end
  
  # ========================================
  # INSTANCE METHODS
  # ========================================
  
  def available?
    status == 'available' && stock.positive?
  end
  
  def sold_out?
    stock.zero? || status == 'sold_out'
  end
  
  def display_price
    "$#{sprintf('%.2f', price)}"
  end

  # Associations (Sajal)
  # Prevent deletion if flower is inside an active cart
  before_destroy :block_if_in_cart

  private

  def block_if_in_cart
    if cart_items.exists?
      errors.add(:base, "Cannot delete this flower because it is currently in a customer's cart.")
      throw :abort
    end
  end
end