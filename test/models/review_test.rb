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
  fixtures :all

  #### Sajal's scopes #####

  def setup
    @flagged = reviews(:flagged_review)
    @normal = reviews(:normal)
  end

  test "flagged review is flagged" do
    assert @flagged.flagged
  end

  test "normal review is not flagged" do
    refute @normal.flagged
  end
  #### Sajal's scopes #####

  #### Sajal M2 PR3 - Auto flagging tests #####

  test "BAD_WORDS constant is defined" do
    assert defined?(Review::BAD_WORDS), "BAD_WORDS constant should be defined"
    assert_kind_of Array, Review::BAD_WORDS
    assert Review::BAD_WORDS.include?("fuck"), "BAD_WORDS should contain 'fuck'"
    assert Review::BAD_WORDS.include?("shit"), "BAD_WORDS should contain 'shit'"
  end

  # Test the private method directly without saving to DB
  test "auto_flag_bad_words flags review with bad words" do
    review = Review.new(comment: "This flower is shit", flagged: false)
    review.send(:auto_flag_bad_words)
    assert review.flagged, "Review should be flagged when comment contains bad word"
  end

  test "auto_flag_bad_words does not flag review without bad words" do
    review = Review.new(comment: "This flower is beautiful and smells nice", flagged: false)
    review.send(:auto_flag_bad_words)
    refute review.flagged, "Review should not be flagged when comment has no bad words"
  end

  test "auto_flag_bad_words handles case insensitive bad words" do
    review = Review.new(comment: "This is FUCKING terrible", flagged: false)
    review.send(:auto_flag_bad_words)
    assert review.flagged, "Review should be flagged even with uppercase bad words"
  end

  test "auto_flag_bad_words does nothing with blank comment" do
    review = Review.new(comment: "", flagged: false)
    review.send(:auto_flag_bad_words)
    refute review.flagged, "Review should not be flagged with blank comment"
  end

  test "auto_flag_bad_words flags review with multiple bad words" do
    review = Review.new(comment: "This is shit and I hate it", flagged: false)
    review.send(:auto_flag_bad_words)
    assert review.flagged, "Review should be flagged with multiple bad words"
  end

  test "auto_flag_bad_words flags review when bad word is part of another word" do
    review = Review.new(comment: "This is bullshit", flagged: false)
    review.send(:auto_flag_bad_words)
    assert review.flagged, "Review should be flagged when bad word is part of another word"
  end

  
test "auto_flag_bad_words returns early for blank comment" do
  review = Review.new(comment: "", flagged: false)
  
  # This tests the `return if comment.blank?` line
  review.send(:auto_flag_bad_words)
  
  refute review.flagged
  # The method should return nil/early, which means the `end` might not be tracked
  # But we've tested the blank comment path
end

test "auto_flag_bad_words executes fully when bad word found" do
  review = Review.new(comment: "fuck", flagged: false)
  
  # This should execute the entire method including the final `end`
  review.send(:auto_flag_bad_words)
  
  assert review.flagged
end

# Also test a word from each part of BAD_WORDS array to ensure full coverage
test "auto_flag_bad_words covers all bad words" do
  # Test one word from the BAD_WORDS array
  Review::BAD_WORDS.each do |bad_word|
    review = Review.new(comment: "This has #{bad_word} in it", flagged: false)
    review.send(:auto_flag_bad_words)
    assert review.flagged, "Should flag review containing '#{bad_word}'"
  end
end


  #### End Sajal M2 PR3 tests #####
end