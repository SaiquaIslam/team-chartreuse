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
require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
