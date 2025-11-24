# == Schema Information
#
# Table name: cart_items
#
#  id               :bigint           not null, primary key
#  quantity         :integer          default(1), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cart_id          :bigint           not null
#  corpse_flower_id :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id           (cart_id)
#  index_cart_items_on_corpse_flower_id  (corpse_flower_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (corpse_flower_id => corpse_flowers.id)
#
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :corpse_flower

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    corpse_flower.price * quantity
  end
end