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
#  user_id              :bigint           not null
#
# Indexes
#
#  index_hunt_registrations_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class HuntRegistration < ApplicationRecord
   belongs_to :user
  # belongs_to :order_item
    has_one_attached :photo

  validates :nickname, presence: true
  validates :location_description, presence: true
  validates :instructions, presence: true
end
