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
require "test_helper"

class HuntRegistrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
