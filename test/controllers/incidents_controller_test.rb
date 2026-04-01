require "test_helper"

class IncidentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @open_incident = logs(:two)
    @resolved_incident = logs(:three)
  end

  # Index

  test "redirects to login when not authenticated" do
    get incidents_path
    assert_redirected_to new_user_session_path
  end

  test "renders index when authenticated" do
    sign_in @user
    get incidents_path
    assert_response :success
  end

  test "index with status=open renders successfully" do
    sign_in @user
    get incidents_path(status: "open")
    assert_response :success
  end

  test "index with status=resolved renders successfully" do
    sign_in @user
    get incidents_path(status: "resolved")
    assert_response :success
  end

  # Resolve

  test "resolve redirects to login when not authenticated" do
    patch resolve_incident_path(@open_incident)
    assert_redirected_to new_user_session_path
  end

  test "resolve marks the incident as resolved" do
    sign_in @user
    patch resolve_incident_path(@open_incident)
    assert @open_incident.reload.resolved?
  end

  test "resolve redirects to incidents path" do
    sign_in @user
    patch resolve_incident_path(@open_incident)
    assert_redirected_to incidents_path
  end

  # Reopen

  test "reopen marks the incident as not resolved" do
    sign_in @user
    patch reopen_incident_path(@resolved_incident)
    assert_not @resolved_incident.reload.resolved?
  end

  test "reopen redirects to incidents path" do
    sign_in @user
    patch reopen_incident_path(@resolved_incident)
    assert_redirected_to incidents_path
  end
end
