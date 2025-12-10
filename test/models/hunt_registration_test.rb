# frozen_string_literal: true

require "test_helper"

class HuntRegistrationTest < ActiveSupport::TestCase
  fixtures :users

  setup do
    @user = users(:regular)
  end

  def build_valid_registration(overrides = {})
    HuntRegistration.new(
      nickname: "Campus Titan",
      location_description: "Near the big fountain",
      instructions: "Look around carefully and upload a picture.",
      latitude: 35.12,
      longitude: -89.94,
      user: @user
    ).tap do |hr|
      overrides.each { |k, v| hr.send("#{k}=", v) }
    end
  end

  ############################################################
  # Basic validity
  ############################################################

  test "valid registration is valid" do
    hr = build_valid_registration
    assert hr.valid?
  end

  ############################################################
  # Presence validations
  ############################################################

  test "requires nickname" do
    hr = build_valid_registration(nickname: nil)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :nickname
  end

  test "requires location_description" do
    hr = build_valid_registration(location_description: nil)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :location_description
  end

  test "requires instructions" do
    hr = build_valid_registration(instructions: nil)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :instructions
  end

  test "requires latitude and longitude" do
    hr = build_valid_registration(latitude: nil, longitude: nil)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :latitude
    assert_includes hr.errors.attribute_names, :longitude
  end

  ############################################################
  # Latitude / longitude ranges
  ############################################################

  test "latitude must be between -90 and 90" do
    hr = build_valid_registration(latitude: 100)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :latitude

    hr.latitude = -100
    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :latitude
  end

  test "longitude must be between -180 and 180" do
    hr = build_valid_registration(longitude: 200)

    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :longitude

    hr.longitude = -200
    assert_not hr.valid?
    assert_includes hr.errors.attribute_names, :longitude
  end

  ############################################################
  # Associations
  ############################################################

  test "belongs_to user" do
    hr = build_valid_registration
    hr.save!
    assert_equal @user, hr.user
  end

  test "order_item is optional" do
    hr = build_valid_registration
    hr.order_item = nil
    assert hr.valid?
  end
end
