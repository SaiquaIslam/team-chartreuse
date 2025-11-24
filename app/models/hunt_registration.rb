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
#
class HuntRegistration < ApplicationRecord
  # belongs_to :user
  # belongs_to :order_item
    has_one_attached :photo

  validates :nickname, presence: true
  validates :location_description, presence: true
  validates :instructions, presence: true
end
