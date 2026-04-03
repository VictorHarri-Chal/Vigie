require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "unauthenticated user is redirected to login" do
    visit root_path
    assert_current_path new_user_session_path
  end

  test "user can sign in with valid credentials" do
    visit new_user_session_path
    fill_in "user_email", with: "agent1@collectivite.fr"
    fill_in "user_password", with: "password123"
    find('input[type="submit"]').click
    assert_current_path root_path
    assert_selector "[data-controller='map']"
  end

  test "user can sign out" do
    sign_in_as users(:one)
    visit root_path
    find("a[href='#{destroy_user_session_path}']").click
    assert_selector "input#user_email"
  end
end
