require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:one)
  end

  test "should get index" do
    get groups_url
    assert_response :success
  end

  test "should show group" do
    get group_url(@group)
    assert_response :success
  end

    assert_redirected_to groups_url
  end
end
