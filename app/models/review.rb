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

# Sajal M2 PR3 - Add flagging functionality to reviews 

BAD_WORDS = %w[
  fuck shit suck idiot stupid scam fraud kill hate trash garbage money job
].freeze

  # Automatically flag review if it contains forbidden words
  before_save :auto_flag_bad_words

  private

  def auto_flag_bad_words
    return if comment.blank?

    lowered_comment = comment.downcase

    if BAD_WORDS.any? { |word| lowered_comment.include?(word) }
      self.flagged = true
    end
  end



end
