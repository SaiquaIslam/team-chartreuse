# frozen_string_literal: true

require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users, :corpse_flowers

  setup do
    @user          = users(:regular)
    @corpse_flower = corpse_flowers(:titan_arum) rescue CorpseFlower.first
  end

  #
  # Helper: simulate that a user has purchased this flower
  #
  def create_order_with_item(user:, flower:)
    order = Order.create!(user: user)

    OrderItem.create!(
      order:         order,
      corpse_flower: flower,
      quantity:      1
    )
  end

  ############################################################
  # AUTHENTICATION
  ############################################################

  test "unauthenticated user is redirected from new" do
    get new_corpse_flower_review_path(@corpse_flower)
    assert_response :redirect
  end

  test "unauthenticated user is redirected from create" do
    post corpse_flower_reviews_path(@corpse_flower), params: {
      review: {
        rating: 5,
        title: "Great flower",
        comment: "Smelly but majestic"
      }
    }
    assert_response :redirect
  end

  ############################################################
  # NEW (purchased vs not purchased)
  ############################################################

  test "user who has NOT purchased is redirected from new with alert" do
    sign_in @user

    # Make sure there is no purchase for this user + flower
    Order.joins(:order_items)
         .where(user: @user, order_items: { corpse_flower_id: @corpse_flower.id })
         .delete_all

    get new_corpse_flower_review_path(@corpse_flower)

    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "You can only review flowers you have purchased.", flash[:alert]
  end

  test "authenticated user who purchased can access new when no existing review" do
    sign_in @user

    # user has purchased this flower → passes ensure_user_purchased_flower!
    create_order_with_item(user: @user, flower: @corpse_flower)
    # and has no existing review
    Review.where(user: @user, corpse_flower: @corpse_flower).delete_all

    get new_corpse_flower_review_path(@corpse_flower)
    assert_response :success
  end

  test "new redirects with alert if user already reviewed this flower" do
    sign_in @user

    create_order_with_item(user: @user, flower: @corpse_flower)

    # Ensure there IS a review for this user/flower, without uniqueness crash
    Review.where(user: @user, corpse_flower: @corpse_flower).first_or_create!(
      rating: 5,
      title: "Already reviewed",
      comment: "Love it"
    )

    get new_corpse_flower_review_path(@corpse_flower)

    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "You have already reviewed this flower.", flash[:alert]
  end

  ############################################################
  # CREATE (purchased vs not purchased)
  ############################################################

  test "user who has NOT purchased is redirected from create and no review is saved" do
    sign_in @user

    # Ensure no purchase exists
    Order.joins(:order_items)
         .where(user: @user, order_items: { corpse_flower_id: @corpse_flower.id })
         .delete_all

    assert_no_difference "Review.count" do
      post corpse_flower_reviews_path(@corpse_flower), params: {
        review: {
          rating: 4,
          title: "Trying to review",
          comment: "But I didn't buy it"
        }
      }
    end

    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "You can only review flowers you have purchased.", flash[:alert]
  end

  test "create saves a valid review and redirects with notice when user purchased" do
    # Use a fresh user so uniqueness (user, corpse_flower) is not violated
    new_user = User.create!(
      email: "new_review_user@example.com",
      password: "password123"
    )

    sign_in new_user

    # satisfy purchase requirement
    create_order_with_item(user: new_user, flower: @corpse_flower)

    assert_difference "Review.count", 1 do
      post corpse_flower_reviews_path(@corpse_flower), params: {
        review: {
          rating: 4,
          title: "Impressive bloom",
          comment: "Smells awful but looks amazing"
        }
      }
    end

    review = Review.last
    assert_equal new_user, review.user
    assert_equal @corpse_flower, review.corpse_flower

    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "Thank you for your review!", flash[:notice]
  end

  test "create re-renders new with error when review is invalid for a purchasing user" do
    invalid_user = User.create!(
      email: "invalid_review_user@example.com",
      password: "password123"
    )

    sign_in invalid_user

    # satisfy purchase requirement
    create_order_with_item(user: invalid_user, flower: @corpse_flower)

    assert_no_difference "Review.count" do
      post corpse_flower_reviews_path(@corpse_flower), params: {
        review: {
          rating: nil,
          title: "",
          comment: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert flash[:alert].present?
  end
end
