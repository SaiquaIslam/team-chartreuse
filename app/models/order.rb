# == Schema Information
#
# Table name: orders
#
#  id               :bigint           not null, primary key
#  shipping_address :string
#  shipping_city    :string
#  shipping_name    :string
#  shipping_phone   :string
#  shipping_state   :string
#  shipping_zip     :string
#  status           :string
#  total_cents      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :corpse_flowers, through: :order_items
end