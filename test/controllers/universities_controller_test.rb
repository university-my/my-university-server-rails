require 'test_helper'

class UniversitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @university = universities(:one)
  end

  test "should get index" do
    get universities_url
    assert_response :success
  end

  test "should show university" do
    get university_url(@university)
    assert_response :success
  end
end
