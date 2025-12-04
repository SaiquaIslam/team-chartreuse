# == Schema Information
#
# Table name: reviews
#
#  id               :bigint           not null, primary key
#  comment          :text             not null
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
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :corpse_flower

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :title, presence: true
  validates :comment, presence: true
  has_one_attached :image

  # One review per user per flower
  validates :user_id, uniqueness: {
    scope: :corpse_flower_id,
    message: "has already reviewed this flower"
  }

  # 👇 NOTE: no extra “must have purchased” validation here.
end
