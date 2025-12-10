# frozen_string_literal: true

require "test_helper"

class HuntRegistrationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users, :corpse_flowers

  setup do
    @user          = users(:regular)
    @corpse_flower = corpse_flowers(:titan_arum) rescue CorpseFlower.first

    @hunt = HuntRegistration.create!(
      user: @user,
      nickname: "Campus Titan",
      location_description: "Near the big fountain",
      instructions: "Look around carefully and upload a picture.",
      latitude: 35.12,
      longitude: -89.94
    )
  end

  #
  # Helper: create a valid order + order_item for this app
  #
  def create_order_with_item(user: @user, flower: @corpse_flower)
    # TODO: if Order has required fields (status, total_amount, etc.),
    # add them here according to your schema / validations.
    order = Order.create!(
      user: user
    )

    # TODO: if OrderItem has required fields (unit_price, etc.),
    # add them here according to your schema / validations.
    order_item = OrderItem.create!(
      order: order,
      corpse_flower: flower,
      quantity: 1
    )

    order_item
  end

  ############################################################
  # INDEX
  ############################################################

  test "index lists registrations without query" do
    get hunt_path
    assert_response :success
    assert_select "body", /Campus Titan/
  end

  test "index filters registrations with query" do
    get hunt_path, params: { query: "Campus" }
    assert_response :success
    assert_select "body", /Campus Titan/
  end

  ############################################################
  # SHOW
  ############################################################

  test "show displays a hunt registration" do
    get hunt_registration_show_path(@hunt)
    assert_response :success
    assert_select "body", /Campus Titan/
  end

  test "show loads corpse_flower when hunt_registration has an order_item" do
    sign_in @user

    order_item = create_order_with_item
    @hunt.update!(order_item: order_item)

    get hunt_registration_show_path(@hunt)
    assert_response :success
    # View should now be able to see the flower name
    assert_select "body", /#{@corpse_flower.name}/
  end

  ############################################################
  # NEW
  ############################################################

  test "unauthenticated user is redirected from new" do
    get new_hunt_registration_path
    assert_response :redirect
  end

  # covers new action with no order_item_id (if-condition false)
  test "authenticated user can access new without order_item_id" do
    sign_in @user
    get new_hunt_registration_path
    assert_response :success
  end

  # covers new action with order_item_id present (if-condition true, but nil order_item)
  test "authenticated user can access new with order_item_id param but missing record" do
    sign_in @user
    get new_hunt_registration_path(order_item_id: 999_999)
    assert_response :success
  end

  # covers new action with order_item_id present AND real order_item (then-branch of &.)
  test "authenticated user can access new with real order_item_id" do
    sign_in @user

    order_item = create_order_with_item

    get new_hunt_registration_path(order_item_id: order_item.id)
    assert_response :success
    # optional: check flower info appears
    assert_select "body", /#{@corpse_flower.name}/
  end

  ############################################################
  # CREATE
  ############################################################

  test "authenticated user can create a hunt registration with valid data" do
    sign_in @user

    assert_difference "HuntRegistration.count", 1 do
      post hunt_registrations_path, params: {
        hunt_registration: {
          nickname: "New Spot",
          location_description: "Behind the statue",
          instructions: "Take a picture and upload it.",
          latitude: 35.13,
          longitude: -89.95
        }
      }
    end

    assert_redirected_to hunt_path
    assert_equal "Registration completed successfully.", flash[:success]
  end

  test "create re-renders new with error when registration is invalid (no order_item)" do
    sign_in @user

    assert_no_difference "HuntRegistration.count" do
      post hunt_registrations_path, params: {
        hunt_registration: {
          nickname: "",
          location_description: "",
          instructions: "",
          latitude: nil,
          longitude: nil
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Unable to save registration.", flash[:error]
  end

  # covers create failure path where order_item is present (then-branch of &.)
  test "create failure still sets order_item and corpse_flower when order_item_id is present" do
    sign_in @user

    order_item = create_order_with_item

    assert_no_difference "HuntRegistration.count" do
      post hunt_registrations_path, params: {
        hunt_registration: {
          order_item_id: order_item.id,
          nickname: "",
          location_description: "",
          instructions: "",
          latitude: nil,
          longitude: nil
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Unable to save registration.", flash[:error]
    # optional: ensure the view can still show flower info
    assert_select "body", /#{@corpse_flower.name}/
  end

  ############################################################
  # EDIT + AUTHORIZATION
  ############################################################

  test "unauthenticated user is redirected from edit" do
    get edit_hunt_registration_path(@hunt)
    assert_response :redirect
  end

  test "owner can access edit" do
    sign_in @user
    get edit_hunt_registration_path(@hunt)
    assert_response :success
  end

  test "non-owner is redirected from edit with alert" do
    other = User.create!(email: "other_hunt@example.com", password: "password123")
    sign_in other

    get edit_hunt_registration_path(@hunt)
    assert_redirected_to hunt_registration_path(@hunt)
    assert_equal "You are not authorized to modify this hunt registration.", flash[:alert]
  end

  ############################################################
  # UPDATE
  ############################################################

  test "owner can update hunt registration with valid data" do
    sign_in @user

    patch hunt_registration_path(@hunt), params: {
      hunt_registration: { nickname: "Updated Nick" }
    }

    assert_redirected_to hunt_registration_path(@hunt)
    assert_equal "Hunt registration updated successfully.", flash[:success]

    @hunt.reload
    assert_equal "Updated Nick", @hunt.nickname
  end

  test "update re-renders edit with error when data is invalid" do
    sign_in @user

    patch hunt_registration_path(@hunt), params: {
      hunt_registration: { nickname: "" }
    }

    assert_response :unprocessable_entity
    assert_equal "Unable to update hunt registration.", flash[:error]
  end

  ############################################################
  # CONFIRM REMOVE
  ############################################################

  test "owner can access confirm_remove" do
    sign_in @user

    get confirm_remove_hunt_registration_path(@hunt)
    assert_response :success
  end

  test "non-owner is redirected from confirm_remove" do
    other = User.create!(email: "other_confirm@example.com", password: "password123")
    sign_in other

    get confirm_remove_hunt_registration_path(@hunt)
    assert_redirected_to hunt_registration_path(@hunt)
    assert_equal "You are not authorized to modify this hunt registration.", flash[:alert]
  end

  ############################################################
  # DESTROY
  ############################################################

  test "owner can destroy hunt registration" do
    sign_in @user

    assert_difference "HuntRegistration.count", -1 do
      delete delete_hunt_registration_path(@hunt)
    end

    assert_redirected_to hunt_path
    assert_equal "Flower was removed from the scavenger hunt.", flash[:success]
  end

  test "non-owner cannot destroy hunt registration" do
    other = User.create!(email: "other_destroy@example.com", password: "password123")
    sign_in other

    assert_no_difference "HuntRegistration.count" do
      delete delete_hunt_registration_path(@hunt)
    end

    assert_redirected_to hunt_registration_path(@hunt)
    assert_equal "You are not authorized to modify this hunt registration.", flash[:alert]
  end
end
