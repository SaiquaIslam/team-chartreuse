# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  total_price :decimal(10, 2)   default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_carts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :corpse_flowers, through: :cart_items

  def calculate_total
    cart_items.sum { |item| item.corpse_flower.price * item.quantity }
  end

  def update_total!
    update(total_price: calculate_total)
  end

  def total_items
    cart_items.sum(:quantity)
  end
end