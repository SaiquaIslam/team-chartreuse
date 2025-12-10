require "test_helper"

class Admin::CorpseFlowersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin       = users(:admin)
    @regular     = users(:regular)
    @flower      = corpse_flowers(:titan_arum)
    @sold_out    = corpse_flowers(:sold_out_flower)
    @locked      = corpse_flowers(:locked_flower)
  end

  # ====== INDEX / NEW ======

  test "admin can view index" do
    sign_in @admin

    get admin_corpse_flowers_path
    assert_response :success
  end

  test "admin can view new flower form" do
    sign_in @admin

    get new_admin_corpse_flower_path
    assert_response :success
  end

  # ====== CREATE ======

  test "admin can create flower with valid params" do
    sign_in @admin

    assert_difference("CorpseFlower.count", +1) do
      post admin_corpse_flowers_path, params: {
        corpse_flower: {
          name:        "New Flower",
          description: "Test description",
          price:       9.99,
          size:        "small",
          color:       "purple",
          putridity:   5,
          stock:       3
        }
      }
    end

    assert_redirected_to admin_corpse_flowers_path
  end

  test "admin cannot create flower with invalid params" do
    sign_in @admin

    assert_no_difference("CorpseFlower.count") do
      post admin_corpse_flowers_path, params: {
        corpse_flower: {
          name:  "",    # invalid
          price: nil    # invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ====== EDIT / UPDATE ======

  test "admin should get edit" do
    sign_in @admin

    get edit_admin_corpse_flower_path(@flower)
    assert_response :success
  end

  test "admin should update flower with valid params" do
    sign_in @admin

    patch admin_corpse_flower_path(@flower), params: {
      corpse_flower: { name: "Updated Name" }
    }

    assert_redirected_to admin_corpse_flowers_path
    @flower.reload
    assert_equal "Updated Name", @flower.name
  end

  test "admin should not update flower with invalid params" do
    sign_in @admin

    patch admin_corpse_flower_path(@flower), params: {
      corpse_flower: { name: "" }
    }

    assert_response :unprocessable_entity
  end

  # ====== DESTROY ======
test "admin should destroy flower successfully" do
  sign_in @admin
  flower = corpse_flowers(:rafflesia)

  assert_difference("CorpseFlower.count", -1) do
    delete admin_corpse_flower_url(flower)
  end

  assert_redirected_to admin_corpse_flowers_url
end


test "admin cannot destroy flower that is in a cart (callback_coverage)" do
  sign_in users(:admin)
  
  # Use titan_arum for this test only
  flower = corpse_flowers(:titan_arum)
  user   = users(:regular)
  
  CartItem.create!(cart: Cart.create!(user: user), corpse_flower: flower, quantity: 1)
  flower.reload
  
  assert_no_difference("CorpseFlower.count") do
    delete admin_corpse_flower_path(flower)
  end
  
  assert_redirected_to admin_corpse_flowers_path
  assert_equal "Cannot delete this flower because it is currently in a customer's cart.", flash[:alert]
  assert CorpseFlower.exists?(flower.id)
end




test "destroy failure still redirects to index" do
  sign_in @admin

  # Use a specific fixture as our special flower
  flower = corpse_flowers(:locked_flower)

  # Make this instance's destroy always fail AND add an error
  def flower.destroy
    errors.add(:base, "Deletion failed in test")
    false
  end

  # Temporarily override CorpseFlower.find so the controller uses
  # THIS instance (with the failing destroy) instead of reloading it fresh.
  original_find = CorpseFlower.method(:find)

  begin
    CorpseFlower.define_singleton_method(:find) do |_id|
      flower
    end

    delete admin_corpse_flower_url(flower)

    # This MUST hit the `else` branch in destroy:
    #   redirect_to admin_corpse_flowers_path,
    #     alert: @corpse_flower.errors.full_messages.to_sentence
    assert_redirected_to admin_corpse_flowers_url
    assert_equal "Deletion failed in test", flash[:alert]
  ensure
    # Restore original find method so other tests are not affected
    CorpseFlower.define_singleton_method(:find, original_find)
  end
end



  # ====== STOCK MANAGEMENT ======

  test "admin should increase stock" do
    sign_in @admin
    old_stock = @flower.stock

    patch increase_stock_admin_corpse_flower_path(@flower)

    assert_redirected_to admin_corpse_flowers_path
    @flower.reload
    assert_equal old_stock + 1, @flower.stock
  end

  test "admin should decrease stock when above zero" do
    sign_in @admin
    @flower.update!(stock: 2)

    patch decrease_stock_admin_corpse_flower_path(@flower)

    assert_redirected_to admin_corpse_flowers_path
    @flower.reload
    assert_equal 1, @flower.stock
  end

  test "admin cannot decrease stock below zero" do
    sign_in @admin
    @sold_out.update!(stock: 0)

    patch decrease_stock_admin_corpse_flower_path(@sold_out)

    assert_redirected_to admin_corpse_flowers_path
    @sold_out.reload
    assert_equal 0, @sold_out.stock
    assert_equal "Stock cannot go below 0.", flash[:alert]
  end

  # ====== AUTHORIZATION ======

  test "non-admin is redirected from index" do
    sign_in @regular

    get admin_corpse_flowers_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "non-admin cannot change stock" do
    sign_in @regular
    old_stock = @flower.stock

    patch increase_stock_admin_corpse_flower_path(@flower)

    assert_redirected_to root_path
    @flower.reload
    assert_equal old_stock, @flower.stock
  end




end
