# == Schema Information
#
# Table name: hunt_registrations
#
#  id                   :bigint           not null, primary key
#  instructions         :text
#  latitude             :decimal(, )
#  location_description :string
#  longitude            :decimal(, )
#  nickname             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  order_item_id        :bigint
#  user_id              :bigint           not null
#
# Indexes
#
#  index_hunt_registrations_on_order_item_id  (order_item_id)
#  index_hunt_registrations_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_item_id => order_items.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class HuntRegistrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
