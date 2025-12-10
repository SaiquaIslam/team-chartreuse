# frozen_string_literal: true

require "test_helper"

class CorpseFlowerTest < ActiveSupport::TestCase
  fixtures :all

  setup do
    @flower        = corpse_flowers(:titan_arum)       # large, purple, 499.99, putridity 8, stock 5
    @sold_out      = corpse_flowers(:sold_out_flower)  # small, yellow, 150.00, putridity 4, stock 0
    @rafflesia     = corpse_flowers(:rafflesia)
    @small_purple  = corpse_flowers(:small_purple)
    @large_red     = corpse_flowers(:large_red)
    @medium_green  = corpse_flowers(:medium_green)
    @locked        = corpse_flowers(:locked_flower)
  end

  # ------------------------------------------------------------
  # BASIC VALIDITY / VALIDATIONS
  # ------------------------------------------------------------

  test "fixture flower is valid" do
    assert @flower.valid?
  end

  test "requires name" do
    flower = CorpseFlower.new(
      price: 10,
      size: "small",
      color: "white",
      putridity: 3,
      stock: 1,
      status: "available"
    )

    assert_not flower.valid?
    assert_includes flower.errors.attribute_names, :name
  end

  test "requires price" do
    flower = CorpseFlower.new(
      name: "No Price",
      size: "small",
      color: "white",
      putridity: 3,
      stock: 1,
      status: "available"
    )

    assert_not flower.valid?
    assert_includes flower.errors.attribute_names, :price
  end

  test "requires size" do
    flower = CorpseFlower.new(
      name: "No Size",
      price: 10,
      color: "white",
      putridity: 3,
      stock: 1,
      status: "available"
    )

    assert_not flower.valid?
    assert_includes flower.errors.attribute_names, :size
  end

  test "requires putridity" do
    flower = CorpseFlower.new(
      name: "No Putridity",
      price: 10,
      size: "small",
      color: "white",
      stock: 1,
      status: "available"
    )

    assert_not flower.valid?
    assert_includes flower.errors.attribute_names, :putridity
  end

  test "price must be non-negative" do
    @flower.price = -10

    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :price
  end

  test "stock must be non-negative integer" do
    @flower.stock = -1
    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :stock

    @flower.stock = 1.5
    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :stock
  end

  test "status must be available or sold_out" do
    @flower.status = "invalid"

    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :status
  end

  test "size must be small medium or large" do
    @flower.size = "giant"

    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :size
  end

  test "putridity must be integer between 1 and 10" do
    @flower.putridity = 0
    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :putridity

    @flower.putridity = 11
    assert_not @flower.valid?
    assert_includes @flower.errors.attribute_names, :putridity
  end

  # ------------------------------------------------------------
  # STOCK & SOLD_OUT STATUS CALLBACK
  # ------------------------------------------------------------

  test "stock increases correctly" do
    original = @flower.stock
    @flower.increment!(:stock)
    assert_equal original + 1, @flower.reload.stock
  end

  test "stock cannot go below zero" do
    @sold_out.update!(stock: 0)
    @sold_out.stock = -3

    assert_not @sold_out.save
    assert_includes @sold_out.errors.attribute_names, :stock
    assert_equal 0, @sold_out.reload.stock
  end

  test "sold_out status is set when stock becomes zero" do
    @sold_out.update!(stock: 0, status: "available")

    @sold_out.send(:update_sold_out_status)

    assert_equal 0, @sold_out.stock
    assert_equal "sold_out", @sold_out.status
  end

  test "status becomes available when stock becomes positive" do
    @sold_out.update!(stock: 0, status: "sold_out")

    @sold_out.update!(stock: 5)
    @sold_out.send(:update_sold_out_status)

    assert_equal "available", @sold_out.status
  end

  # ------------------------------------------------------------
  # block_if_in_cart CALLBACK
  # ------------------------------------------------------------

  test "cannot destroy a flower that is in a cart" do
    user = users(:regular)
    cart = Cart.create!(user: user)
    CartItem.create!(cart: cart, corpse_flower: @flower, quantity: 1)

    @flower.reload
    @flower.cart_items.reload

    assert_no_difference "CorpseFlower.count" do
      result = @flower.destroy
      assert_not result
    end

    assert_includes @flower.errors[:base],
      "Cannot delete this flower because it is currently in a customer's cart."
  end

  test "can destroy a flower if not in any cart" do
    flower = CorpseFlower.create!(
      name: "Disposable Flower",
      description: "For deletion tests",
      price: 10,
      size: "small",
      color: "white",
      putridity: 3,
      stock: 1,
      status: "available"
    )

    assert_difference "CorpseFlower.count", -1 do
      flower.destroy
    end
  end

  # ------------------------------------------------------------
  # FILTER SCOPES
  # ------------------------------------------------------------

  test "filter_by_size returns only flowers with requested sizes" do
    results = CorpseFlower.filter_by_size(%w[small medium])

    assert results.all? { |f| %w[small medium].include?(f.size) }
    names = results.map(&:name)
    assert_includes names, "Small Purple Delight"
    assert_includes names, "Rafflesia"
    refute_includes names, "Large Red Beauty"
  end

  test "filter_by_size does nothing when sizes is blank" do
    # Exercise the false branch of `if sizes.present?`
    scope = CorpseFlower.filter_by_size(nil)
    # just ensure it returns a relation
    assert_kind_of ActiveRecord::Relation, scope
  end

  test "filter_by_color returns only flowers with requested colors" do
    results = CorpseFlower.filter_by_color(%w[purple])

    assert results.all? { |f| f.color == "purple" }
    names = results.map(&:name)
    assert_includes names, "Titan Arum"
    assert_includes names, "Small Purple Delight"
    refute_includes names, "Rafflesia"
  end

  test "filter_by_color does nothing when colors is blank" do
    scope = CorpseFlower.filter_by_color(nil)
    assert_kind_of ActiveRecord::Relation, scope
  end

  test "filter_by_putridity_range returns inclusive range" do
    # 4–6: sold_out_flower (4), small_purple (5), medium_green (6)
    results = CorpseFlower.filter_by_putridity_range("4-6")

    assert results.all? { |f| f.putridity.between?(4, 6) }
    names = results.map(&:name)
    assert_includes names, "Sold Out Specimen"
    assert_includes names, "Small Purple Delight"
    assert_includes names, "Medium Green Wonder"
    refute_includes names, "Rafflesia"
  end

  test "filter_by_putridity returns flowers with matching levels" do
    results = CorpseFlower.filter_by_putridity([5, 7])

    assert results.all? { |f| [5, 7].include?(f.putridity) }
    names = results.map(&:name)
    assert_includes names, "Small Purple Delight" # 5
    assert_includes names, "Large Red Beauty"     # 7
    refute_includes names, "Titan Arum"           # 8
  end

  test "filter_by_putridity does nothing when levels is blank" do
    scope = CorpseFlower.filter_by_putridity(nil)
    assert_kind_of ActiveRecord::Relation, scope
  end

  # ------------------------------------------------------------
  # SEARCH
  # ------------------------------------------------------------

  test "search matches name and description case-insensitively" do
    results = CorpseFlower.search("purple")
    names = results.map(&:name)

    assert_includes names, "Titan Arum"
    assert_includes names, "Small Purple Delight"
    refute_includes names, "Rafflesia"
  end

  test "search does nothing when query is blank" do
    scope = CorpseFlower.search(nil)
    assert_kind_of ActiveRecord::Relation, scope
  end

  # ------------------------------------------------------------
  # DISTINCT HELPERS
  # ------------------------------------------------------------

  test "distinct_colors returns unique set of colors" do
    colors = CorpseFlower.distinct_colors.sort
    expected = %w[blue green purple red yellow].sort
    assert_equal expected, colors
  end

  test "distinct_sizes returns unique set of sizes" do
    sizes = CorpseFlower.distinct_sizes.sort
    expected = %w[small medium large].sort
    assert_equal expected, sizes
  end

  test "distinct_putridity_levels returns unique set of putridity values" do
    levels = CorpseFlower.distinct_putridity_levels.sort
    expected = [4, 5, 6, 7, 8, 9].sort
    assert_equal expected, levels
  end

  # ------------------------------------------------------------
  # SORT SCOPES + apply_sort
  # ------------------------------------------------------------

  def assert_non_decreasing(array)
    array.each_cons(2) { |a, b| assert a <= b, "Expected non-decreasing order but #{a} > #{b}" }
  end

  def assert_non_increasing(array)
    array.each_cons(2) { |a, b| assert a >= b, "Expected non-increasing order but #{a} < #{b}" }
  end

  test "sort_by_price_asc orders by price ascending" do
    prices = CorpseFlower.sort_by_price_asc.pluck(:price)
    assert_non_decreasing prices
  end

  test "sort_by_price_desc orders by price descending" do
    prices = CorpseFlower.sort_by_price_desc.pluck(:price)
    assert_non_increasing prices
  end

  test "sort_by_putridity_asc orders by putridity ascending" do
    values = CorpseFlower.sort_by_putridity_asc.pluck(:putridity)
    assert_non_decreasing values
  end

  test "sort_by_putridity_desc orders by putridity descending" do
    values = CorpseFlower.sort_by_putridity_desc.pluck(:putridity)
    assert_non_increasing values
  end

  test "sort_by_newest orders by created_at descending" do
    created = CorpseFlower.sort_by_newest.pluck(:created_at)
    assert_non_increasing created
  end

  test "sort_by_size_asc uses small < medium < large ordering" do
    weights = { "small" => 1, "medium" => 2, "large" => 3 }
    mapped = CorpseFlower.sort_by_size_asc.map { |f| weights.fetch(f.size) }
    assert_non_decreasing mapped
  end

  test "sort_by_size_desc uses large > medium > small ordering" do
    weights = { "small" => 1, "medium" => 2, "large" => 3 }
    mapped = CorpseFlower.sort_by_size_desc.map { |f| weights.fetch(f.size) }
    assert_non_increasing mapped
  end

  test "apply_sort delegates to correct sort scope and default newest" do
    assert_equal CorpseFlower.sort_by_price_asc.pluck(:id),
                 CorpseFlower.apply_sort("price_asc").pluck(:id)
    assert_equal CorpseFlower.sort_by_price_desc.pluck(:id),
                 CorpseFlower.apply_sort("price_desc").pluck(:id)
    assert_equal CorpseFlower.sort_by_size_asc.pluck(:id),
                 CorpseFlower.apply_sort("size_asc").pluck(:id)
    assert_equal CorpseFlower.sort_by_size_desc.pluck(:id),
                 CorpseFlower.apply_sort("size_desc").pluck(:id)
    assert_equal CorpseFlower.sort_by_putridity_asc.pluck(:id),
                 CorpseFlower.apply_sort("putridity_asc").pluck(:id)
    assert_equal CorpseFlower.sort_by_putridity_desc.pluck(:id),
                 CorpseFlower.apply_sort("putridity_desc").pluck(:id)
    assert_equal CorpseFlower.sort_by_newest.pluck(:id),
                 CorpseFlower.apply_sort("newest").pluck(:id)
  end

  test "apply_sort falls back to newest for unknown option" do
    expected = CorpseFlower.sort_by_newest.pluck(:id)
    actual   = CorpseFlower.apply_sort("unknown_sort").pluck(:id)
    assert_equal expected, actual
  end

  # ------------------------------------------------------------
  # INSTANCE METHODS
  # ------------------------------------------------------------

  test "available? returns true only when status available and stock positive" do
    flower = CorpseFlower.new(
      name: "Test",
      description: "Testing",
      price: 10,
      size: "small",
      color: "white",
      putridity: 3,
      stock: 2,
      status: "available"
    )

    assert_equal true, flower.available?

    flower.status = "sold_out"
    assert_equal false, flower.available?

    flower.status = "available"
    flower.stock = 0
    assert_equal false, flower.available?
  end

  test "sold_out? returns true when stock is zero or status sold_out" do
    flower = CorpseFlower.new(
      name: "Test",
      description: "Testing",
      price: 10,
      size: "small",
      color: "white",
      putridity: 3,
      stock: 0,
      status: "available"
    )

    assert_equal true, flower.sold_out?

    flower.stock = 5
    flower.status = "sold_out"
    assert_equal true, flower.sold_out?

    flower.status = "available"
    assert_equal false, flower.sold_out?
  end

  test "display_price formats price with dollar sign and two decimals" do
    @flower.update!(price: 42)
    assert_equal "$42.00", @flower.display_price
  end
end
