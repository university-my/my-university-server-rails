require 'test_helper'

class TeachersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
    @university = universities(:sumdu)
  end

  test "should get index" do
    get university_teachers_url(@university.url)
    assert_response :success
  end

  test "should show teacher" do
    get university_teacher_url(@university.url, @teacher)
    assert_response :success
  end
end
