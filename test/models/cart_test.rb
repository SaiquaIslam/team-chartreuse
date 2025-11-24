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
require "test_helper"

class CartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
