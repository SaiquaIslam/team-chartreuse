# == Schema Information
#
# Table name: order_items
#
#  id               :bigint           not null, primary key
#  price_cents      :integer
#  quantity         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corpse_flower_id :bigint           not null
#  order_id         :bigint           not null
#
# Indexes
#
#  index_order_items_on_corpse_flower_id  (corpse_flower_id)
#  index_order_items_on_order_id          (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (corpse_flower_id => corpse_flowers.id)
#  fk_rails_...  (order_id => orders.id)
#
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :corpse_flower
end
