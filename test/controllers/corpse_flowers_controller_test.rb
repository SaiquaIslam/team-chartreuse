require "test_helper"

class CorpseFlowersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corpse_flowers_index_url
    assert_response :success
  end

  test "should get show" do
    get corpse_flowers_show_url
    assert_response :success
  end
end
