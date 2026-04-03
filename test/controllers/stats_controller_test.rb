require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "redirects to login when not authenticated" do
    get stats_path
    assert_redirected_to new_user_session_path
  end

  test "renders index when authenticated" do
    sign_in @user
    get stats_path
    assert_response :success
  end
end
