# == Schema Information
#
# Table name: reviews
#
#  id               :bigint           not null, primary key
#  comment          :text             not null
#  flagged          :boolean          default(FALSE)
#  photo            :string
#  rating           :integer          not null
#  title            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corpse_flower_id :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_reviews_on_corpse_flower_id              (corpse_flower_id)
#  index_reviews_on_user_id                       (user_id)
#  index_reviews_on_user_id_and_corpse_flower_id  (user_id,corpse_flower_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (corpse_flower_id => corpse_flowers.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
