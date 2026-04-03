require "test_helper"

class ToursControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "redirects to login when not authenticated" do
    get tour_planner_path
    assert_redirected_to new_user_session_path
  end

  test "renders index when authenticated" do
    sign_in @user
    get tour_planner_path
    assert_response :success
  end

  test "index includes pavs json in response body" do
    sign_in @user
    get tour_planner_path
    assert_match "tour-planner", response.body
  end
end
