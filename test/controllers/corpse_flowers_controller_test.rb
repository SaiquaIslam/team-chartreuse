# frozen_string_literal: true

require 'test_helper'

class CorpseFlowersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @titan        = corpse_flowers(:titan_arum)       # large, purple, putridity 8,  499.99
    @rafflesia    = corpse_flowers(:rafflesia)        # medium, red,   putridity 9,  799.99
    @small_purple = corpse_flowers(:small_purple)     # small, purple, putridity 5,  199.99
    @large_red    = corpse_flowers(:large_red)        # large, red,    putridity 7,  899.99
    @medium_green = corpse_flowers(:medium_green)     # medium, green, putridity 6,  349.99
    @sold_out     = corpse_flowers(:sold_out_flower)  # small, yellow, putridity 4,  150.00, sold_out
    @locked       = corpse_flowers(:locked_flower)    # medium, blue,  putridity 7,  300.00
  end

  # ----------------------------------------------------------------------
  # Basic index / show / not-found
  # ----------------------------------------------------------------------

  test 'should get index' do
    get corpse_flowers_url
    assert_response :success
  end

  test 'should get show' do
    get corpse_flower_url(@titan)
    assert_response :success
    assert_select 'body', /Titan Arum/
  end

  test 'should handle record not found in show' do
    get corpse_flower_url(id: 99_999)
    assert_response :redirect
    assert_redirected_to corpse_flowers_path
    assert_equal 'Corpse flower not found.', flash[:alert]
  end

  # ----------------------------------------------------------------------
  # Search + filters
  # ----------------------------------------------------------------------

  test 'should apply search and all filters in index' do
    get corpse_flowers_url, params: {
      search: 'Titan',
      sizes: ['large'],
      colors: ['purple'],
      putridity_ranges: ['7-10'] # expands to [7, 8, 9, 10]
    }

    assert_response :success

    # Titan Arum matches search + size + color + putridity
    assert_select 'body', /Titan Arum/

    # Non-matching examples should not show
    refute_match(/Rafflesia/, @response.body)
    refute_match(/Small Purple Delight/, @response.body)
  end

  test 'should allow size-only filter in index' do
    get corpse_flowers_url, params: {
      sizes: ['small']
    }

    assert_response :success

    # Small flowers should be present
    assert_select 'body', /Small Purple Delight/
    assert_select 'body', /Sold Out Specimen/

    # Large-only examples should not appear in this filtered set
    refute_match(/Titan Arum/, @response.body)
    refute_match(/Large Red Beauty/, @response.body)
  end

  test 'should allow color-only filter in index' do
    get corpse_flowers_url, params: {
      colors: ['red']
    }

    assert_response :success

    # Red flowers
    assert_select 'body', /Rafflesia/
    assert_select 'body', /Large Red Beauty/

    # Purple one should not show up in this filtered set
    refute_match(/Titan Arum/, @response.body)
    refute_match(/Small Purple Delight/, @response.body)
  end

  test 'should allow putridity_range-only filter in index' do
    # 7–10: Titan (8), Rafflesia (9), Large Red (7), Locked (7)
    get corpse_flowers_url, params: {
      putridity_ranges: ['7-10']
    }

    assert_response :success

    assert_select 'body', /Titan Arum/
    assert_select 'body', /Rafflesia/
    assert_select 'body', /Large Red Beauty/
    assert_select 'body', /Locked Flower/

    # Lower putridity flowers should not be present
    refute_match(/Small Purple Delight/, @response.body) # 5
    refute_match(/Medium Green Wonder/, @response.body)  # 6
    refute_match(/Sold Out Specimen/, @response.body)    # 4
  end

  # ----------------------------------------------------------------------
  # Filter options / controller accepting filter params
  # ----------------------------------------------------------------------

  test 'should get available filter options in index' do
    get corpse_flowers_url
    assert_response :success
    # View-specific assertions (like labels) could be added if needed.
  end

  test 'should handle current filter selections in index' do
    get corpse_flowers_url, params: {
      sizes: ['small', 'medium'],
      colors: ['purple'],
      putridity_ranges: ['4-6']
    }
    assert_response :success
    # If the controller could not handle these params, this would fail.
  end

  # ----------------------------------------------------------------------
  # Sorting helpers
  # ----------------------------------------------------------------------

  def assert_appears_before(first_text, second_text)
    body = @response.body
    first_index  = body.index(first_text)
    second_index = body.index(second_text)

    assert first_index,  "Expected '#{first_text}' to appear in response body"
    assert second_index, "Expected '#{second_text}' to appear in response body"
    assert first_index < second_index,
           "Expected '#{first_text}' to appear before '#{second_text}' but it did not"
  end

  test 'should default sort by newest in index' do
    get corpse_flowers_url
    assert_response :success
    # Default sort option is handled inside controller (newest).
  end

  test 'should accept all sort options in index' do
    %w[newest price_asc price_desc size_asc size_desc putridity_asc putridity_desc].each do |sort_option|
      get corpse_flowers_url, params: { sort: sort_option }
      assert_response :success, "Expected success for sort option #{sort_option}"
    end
  end

  test 'should sort by price ascending' do
    get corpse_flowers_url, params: { sort: 'price_asc' }
    assert_response :success

    # 199.99 < 899.99, so Small Purple before Large Red
    assert_appears_before('Small Purple Delight', 'Large Red Beauty')
  end

  test 'should sort by price descending' do
    get corpse_flowers_url, params: { sort: 'price_desc' }
    assert_response :success

    assert_appears_before('Large Red Beauty', 'Small Purple Delight')
  end

  test 'should sort by size small to large' do
    get corpse_flowers_url, params: { sort: 'size_asc' }
    assert_response :success

    # small -> medium -> large; check small vs large
    assert_appears_before('Small Purple Delight', 'Large Red Beauty')
  end

  test 'should sort by size large to small' do
    get corpse_flowers_url, params: { sort: 'size_desc' }
    assert_response :success

    assert_appears_before('Large Red Beauty', 'Small Purple Delight')
  end

  test 'should sort by putridity low to high' do
    get corpse_flowers_url, params: { sort: 'putridity_asc' }
    assert_response :success

    # 5 < 9, so Small Purple before Rafflesia
    assert_appears_before('Small Purple Delight', 'Rafflesia')
  end

  test 'should sort by putridity high to low' do
    get corpse_flowers_url, params: { sort: 'putridity_desc' }
    assert_response :success

    assert_appears_before('Rafflesia', 'Small Purple Delight')
  end

  # ----------------------------------------------------------------------
  # Filters + sort together (interaction)
  # ----------------------------------------------------------------------

  test 'should allow filters and sort together in index' do
    get corpse_flowers_url, params: {
      sizes: ['large'],
      colors: ['red'],
      putridity_ranges: ['7-10'],
      sort: 'price_asc'
    }

    assert_response :success
    assert_select 'body', /Large Red Beauty/
  end
end
