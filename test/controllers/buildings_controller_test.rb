require 'test_helper'

class BuildingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @building = buildings(:one)
    @university = universities(:sumdu)
  end

  test "should get index" do
    get university_buildings_url(@university.url)
    assert_response :success
  end

  test "should show building" do
    get university_building_url(@university.url, @building)
    assert_response :success
  end
end
