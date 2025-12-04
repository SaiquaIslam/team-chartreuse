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

  ############################################################
  # Validations
  ############################################################
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available sold_out] }
  validates :size, presence: true, inclusion: { in: %w[small medium large] }
  validates :putridity, presence: true, numericality: { only_integer: true, in: 1..10 }

  ############################################################
  # Associations
  ############################################################
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  has_many_attached :images

  has_many :reviews, dependent: :destroy
>>>>>>> Stashed changes

  # Rafy associations
  has_many :order_items
  has_many :orders, through: :order_items

  ############################################################
  # Filter Scopes (M2 PR1)
  ############################################################

  # Size filter: params[:sizes] → ["small", "medium"]
  scope :filter_by_size, ->(sizes) do
    where(size: sizes) if sizes.present?
  end

  # Color filter: params[:colors] → ["Dark Purple", "Cherry Pink"]
  scope :filter_by_color, ->(colors) do
    where(color: colors) if colors.present?
  end

  # Range string like "1-3", "4-6"
  scope :filter_by_putridity_range, ->(range_str) do
    from, to = range_str.split("-").map(&:to_i)
    where(putridity: from..to)
  end

  # ✅ Used by controller after expand_putridity_ranges
  #    putridity_levels → [1, 2, 3]
  scope :filter_by_putridity, ->(levels) do
    where(putridity: levels) if levels.present?
  end

  ############################################################
  # Distinct values for sidebar filtering
  ############################################################
  def self.distinct_colors
    distinct.pluck(:color).compact
  end

  def self.distinct_sizes
    distinct.pluck(:size).compact
  end

  def self.distinct_putridity_levels
    distinct.pluck(:putridity).compact
  end

  ############################################################
  # Search Scope
  ############################################################
  scope :search, ->(term) {
    where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?",
          "%#{term.downcase}%", "%#{term.downcase}%") if term.present?
  }

  ############################################################
  # Instance Methods
  ############################################################
  def available?
    status == "available" && stock.positive?
  end

  def sold_out?
    stock.zero? || status == "sold_out"
  end

  def display_price
    "$#{sprintf('%.2f', price)}"
  end

  ############################################################
  # Callbacks
  ############################################################

  # Prevent deleting a flower if it appears in any active cart
  before_destroy :block_if_in_cart

  # Auto-update status based on stock (US20)
  before_save :update_sold_out_status

  private

  def block_if_in_cart
    if cart_items.exists?
      errors.add(:base, "Cannot delete this flower because it is currently in a customer's cart.")
      throw :abort
    end
  end

  def update_sold_out_status
    if stock.to_i <= 0
      self.stock = 0
      self.status = "sold_out"
    else
      self.status = "available"
    end
  end
end
