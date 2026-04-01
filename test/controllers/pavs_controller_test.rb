require "test_helper"

class PavsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @pav = pavs(:one)
  end

  # Index

  test "redirects to login when not authenticated" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "renders index when authenticated" do
    sign_in @user
    get root_path
    assert_response :success
  end

  # Show

  test "redirects to login on show when not authenticated" do
    get pav_path(@pav)
    assert_redirected_to new_user_session_path
  end

  test "renders show when authenticated" do
    sign_in @user
    get pav_path(@pav)
    assert_response :success
  end

  test "shows back link to incidents when from=incidents" do
    sign_in @user
    get pav_path(@pav, from: "incidents")
    assert_response :success
    assert_select "a[href='#{incidents_path}'][data-turbo-frame='_top']"
  end

  test "shows close button instead of back link by default" do
    sign_in @user
    get pav_path(@pav)
    assert_response :success
    assert_select "a[href='#{incidents_path}'][data-turbo-frame='_top']", false
    assert_select "button[data-action='click->map#closePanel']"
  end
end
