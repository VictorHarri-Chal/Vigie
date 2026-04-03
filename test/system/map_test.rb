require "application_system_test_case"

class MapTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
  end

  test "map page loads with the leaflet container" do
    visit root_path
    assert_selector "[data-controller='map']"
    assert_selector "#map"
  end

  test "stats overlay shows pav count and open incidents" do
    visit root_path
    assert_text "2"
    assert_text "PAVs"
  end

  test "pav show page renders when accessed directly" do
    visit pav_path(pavs(:one))
    assert_text "PAV Fixture Verre"
    assert_selector "[data-controller='tabs']"
  end
end
