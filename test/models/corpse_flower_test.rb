# frozen_string_literal: true

require "test_helper" 

class CorpseFlowerTest < ActiveSupport::TestCase
  fixtures :all
  setup do
    @flower   = corpse_flowers(:titan_arum)
    @sold_out = corpse_flowers(:sold_out_flower)
  end

  # -------------------------
  # Stock / sold_out status
  # -------------------------

  test "stock increases correctly" do
    original_stock = @flower.stock

    @flower.increment!(:stock)

    assert_equal original_stock + 1, @flower.reload.stock
  end

  test "stock cannot go below zero" do
  @sold_out.update!(stock: 0)
  
  # Don't try to save with negative stock - test the validation
  @sold_out.stock = -5
  
  # This should fail validation
  assert_not @sold_out.save
  assert_includes @sold_out.errors[:stock], "must be greater than or equal to 0"
  assert_equal 0, @sold_out.reload.stock  # Still 0 after reload
end

  test "sold_out flower has zero stock and sold_out status when stock is non-positive" do
  # Start with zero stock
  @sold_out.update!(stock: 0, status: "available")
  
  # Manually trigger the callback
  @sold_out.send(:update_sold_out_status)
  
  assert_equal 0, @sold_out.stock
  assert_equal "sold_out", @sold_out.status
end
  # -------------------------
  # block_if_in_cart callback
  # -------------------------

  test "cannot destroy a flower that is in a cart" do
  user = users(:regular)

  cart = Cart.create!(user: user)
  CartItem.create!(cart: cart, corpse_flower: @flower, quantity: 1)

  # Reload both the flower and the association so Rails sees it
  @flower.reload
  @flower.cart_items.reload

  assert_no_difference "CorpseFlower.count" do
    result = @flower.destroy
    assert_not result
  end

  assert_includes @flower.errors[:base],
    "Cannot delete this flower because it is currently in a customer's cart."
end

end
