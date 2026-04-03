require "application_system_test_case"

class IncidentsTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
  end

  test "incidents page lists all incidents" do
    visit incidents_path
    assert_selector "table"
    assert_text "PAV Fixture Papier"
    assert_text "PAV Fixture Verre"
  end

  test "filtering by open shows only unresolved incidents" do
    visit incidents_path
    click_link "Ouverts"
    assert_current_path incidents_path(status: "open")
    assert_text "PAV Fixture Papier"
    assert_no_text "PAV Fixture Verre"
  end

  test "filtering by resolved shows only resolved incidents" do
    visit incidents_path
    click_link "Résolus"
    assert_current_path incidents_path(status: "resolved")
    assert_text "PAV Fixture Verre"
    assert_no_text "PAV Fixture Papier"
  end

  test "resolving an incident marks it as resolved" do
    visit incidents_path(status: "open")
    click_button "Résoudre"
    assert_selector "[data-confirm-target='dialog']", visible: true
    click_button "Confirmer"
    assert_current_path incidents_path
    visit incidents_path(status: "open")
    assert_no_text "PAV Fixture Papier"
  end
end
