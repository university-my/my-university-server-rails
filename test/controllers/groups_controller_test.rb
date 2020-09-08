require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:one)
    @university = universities(:sumdu)
  end

  test "should get index" do
    get university_groups_url(@university.url)
    assert_response :success
  end

  test "should show group" do
    get university_group_url(@university.url, @group)
    assert_response :success
  end
end
