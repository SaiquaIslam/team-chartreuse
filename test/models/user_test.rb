# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users, :corpse_flowers

  ############################################################
  # display_name
  ############################################################

  test "display_name returns everything before the @" do
    user = users(:regular)
    assert_equal user.email.split("@").first, user.display_name
  end

  ############################################################
  # purchased_corpse_flower?
  ############################################################

  test "purchased_corpse_flower? returns true when user has an order containing that flower" do
    user   = users(:regular)
    flower = corpse_flowers(:titan_arum)

    order = Order.create!(user: user, total_cents: 2000, status: "paid")
    order.order_items.create!(
      corpse_flower: flower,
      quantity: 1,
      price_cents: 2000
    )

    assert user.purchased_corpse_flower?(flower),
           "Expected purchased_corpse_flower? to return true"
  end

  test "purchased_corpse_flower? returns false when flower was not purchased by user" do
    user   = users(:regular)
    flower = corpse_flowers(:titan_arum)

    # No orders created
    refute user.purchased_corpse_flower?(flower)
  end

  ############################################################
  # active_for_authentication? (branch coverage)
  ############################################################

  test "active_for_authentication? returns true when user is not suspended" do
    user = users(:regular)
    user.update!(suspended: false)

    assert user.active_for_authentication?
  end

  test "active_for_authentication? returns false when user is suspended" do
    user = users(:regular)
    user.update!(suspended: true)

    refute user.active_for_authentication?
  end

  ############################################################
  # inactive_message (branch coverage)
  ############################################################

  test "inactive_message returns :suspended when user is suspended" do
    user = users(:regular)
    user.update!(suspended: true)

    assert_equal :suspended, user.inactive_message
  end

  test "inactive_message returns Devise default when user is not suspended" do
    user = users(:regular)
    user.update!(suspended: false)

    # super returns a symbol from Devise, usually :inactive
    # We don't hardcode it — we call super indirectly
    assert_not_equal :suspended, user.inactive_message
  end
end
