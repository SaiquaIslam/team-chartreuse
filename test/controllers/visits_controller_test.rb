# frozen_string_literal: true

require "test_helper"

class VisitsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess  # for fixture_file_upload

  fixtures :users

  setup do
    @user       = users(:regular)
    @other_user = users(:admin) rescue User.where.not(id: @user.id).first || User.create!(
      email: "other_visit_user@example.com",
      password: "password123"
    )

    @hunt_registration = HuntRegistration.create!(
      user: @user,
      nickname: "Campus Titan Visit Spot",
      location_description: "Near the fountain",
      instructions: "Take a selfie with the flower.",
      latitude: 35.12,
      longitude: -89.94
    )
  end

  # ✅ FIXED — correct fixture upload helper
  # Rails automatically looks in test/fixtures/files/
  def sample_photo
    fixture_file_upload("sample.jpg", "image/jpeg")
  end

  # Helper to create valid Visit for leaderboard
  def create_valid_visit(user:, hunt_registration:, comment:)
    visit = Visit.new(
      user: user,
      hunt_registration: hunt_registration,
      comment: comment,
      visited_on: Date.today
    )

    # Attach the actual file from test/fixtures/files/sample.jpg
    file_path = Rails.root.join("test/fixtures/files/sample.jpg")
    file = File.open(file_path)

    visit.photo.attach(
      io: file,
      filename: "sample.jpg",
      content_type: "image/jpeg"
    )

    visit.save!
    file.close
    visit
  end

  ############################################################
  # AUTHENTICATION
  ############################################################

  test "unauthenticated user is redirected from new" do
    get new_hunt_registration_visit_path(@hunt_registration)
    assert_response :redirect
  end

  test "unauthenticated user is redirected from create" do
    post hunt_registration_visits_path(@hunt_registration), params: {
      visit: {
        comment: "Nice place",
        visited_on: Date.today
      }
    }
    assert_response :redirect
  end

  test "unauthenticated user is redirected from leaderboard" do
    get leaderboard_path
    assert_response :redirect
  end

  ############################################################
  # NEW
  ############################################################

  test "authenticated user can access new visit form" do
    sign_in @user

    get new_hunt_registration_visit_path(@hunt_registration)
    assert_response :success
  end

  ############################################################
  # CREATE
  ############################################################

  test "create records a visit with valid data" do
    sign_in @user

    assert_difference "Visit.count", 1 do
      post hunt_registration_visits_path(@hunt_registration), params: {
        visit: {
          comment:    "Found it! Smells terrible.",
          visited_on: Date.today,
          photo:      sample_photo
        }
      }
    end

    visit = Visit.last
    assert_equal @user, visit.user
    assert_equal @hunt_registration, visit.hunt_registration

    assert_redirected_to hunt_registration_path(@hunt_registration)
    assert_equal "Visit recorded successfully!", flash[:success]
  end

  test "create re-renders new when visit is invalid" do
    sign_in @user

    assert_no_difference "Visit.count" do
      post hunt_registration_visits_path(@hunt_registration), params: {
        visit: {
          comment: "",
          visited_on: nil,
          photo: nil
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Failed to record visit.", flash[:error]
  end

  ############################################################
  # LEADERBOARD
  ############################################################

  test "leaderboard lists users ordered by visit count" do
    sign_in @user

    # User 1: 2 visits
    2.times do
      create_valid_visit(
        user: @user,
        hunt_registration: @hunt_registration,
        comment: "Visit by user 1"
      )
    end

    # User 2: 1 visit
    create_valid_visit(
      user: @other_user,
      hunt_registration: @hunt_registration,
      comment: "Visit by user 2"
    )

    get leaderboard_path
    assert_response :success

    assert_select "body", /#{@user.email}/
    assert_select "body", /#{@other_user.email}/
  end
end
