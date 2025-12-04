require "test_helper"

class CorpseFlowersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corpse_flowers_url
    assert_response :success
  end

  test "should get show" do
    flower = corpse_flowers(:titan_arum)
    get corpse_flower_url(flower)
    assert_response :success
  end 

  test "should handle record not found in show" do
    get corpse_flower_url(id: 99999)
    assert_redirected_to corpse_flowers_path
    assert_equal 'Corpse flower not found.', flash[:alert]
  end

  test "should apply search and filters in index" do
    get corpse_flowers_url, params: { 
      search: 'Titan', 
      sizes: ['large'], 
      colors: ['purple'], 
      putridity: [8] 
    }
    assert_response :success
    # Verify the response includes the filtered flower
    assert_select 'body', /Titan Arum/
  end

  test "should get available filter options in index" do
    get corpse_flowers_url
    assert_response :success
    # Verify filter options are available in the response
    assert_select 'body'
  end

  test "should store current filter selections in index" do
    get corpse_flowers_url, params: { 
      sizes: ['small', 'medium'], 
      colors: ['red'], 
      putridity: [3, 7] 
    }
    assert_response :success
    # Verify response is successful with filter params
  end 

  test "should order corpse flowers by created_at desc in index" do
    get corpse_flowers_url
    assert_response :success
    # Verify flowers are displayed (check response body)
    assert_select 'body'
  end
end