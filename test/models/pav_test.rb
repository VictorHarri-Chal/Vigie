require "test_helper"

class PavTest < ActiveSupport::TestCase
  # Validations

  test "is valid with all required fields" do
    pav = Pav.new(pav_id: "pav-new", name: "PAV Test", waste_type: "verre")
    assert pav.valid?
  end

  test "is invalid without pav_id" do
    pav = Pav.new(name: "PAV Test", waste_type: "verre")
    assert_not pav.valid?
    assert_includes pav.errors[:pav_id], "can't be blank"
  end

  test "is invalid without name" do
    pav = Pav.new(pav_id: "pav-new", waste_type: "verre")
    assert_not pav.valid?
    assert_includes pav.errors[:name], "can't be blank"
  end

  test "is invalid without waste_type" do
    pav = Pav.new(pav_id: "pav-new", name: "PAV Test")
    assert_not pav.valid?
    assert_includes pav.errors[:waste_type], "can't be blank"
  end

  test "is invalid with duplicate pav_id" do
    pav = Pav.new(pav_id: "pav-fixture-01", name: "Autre", waste_type: "verre")
    assert_not pav.valid?
    assert_includes pav.errors[:pav_id], "has already been taken"
  end

  # Scopes

  test "by_waste_type returns only matching pavs" do
    result = Pav.by_waste_type("verre")
    assert_includes result, pavs(:one)
    assert_not_includes result, pavs(:two)
  end

  # current_fill_percent

  test "current_fill_percent returns the latest sensor reading value" do
    assert_equal 42, pavs(:one).current_fill_percent
  end

  test "current_fill_percent returns nil when no sensor readings" do
    assert_nil pavs(:two).current_fill_percent
  end

  # overfull?

  test "overfull? returns false when fill is below 90" do
    assert_not pavs(:one).overfull?
  end

  test "overfull? returns false when no sensor readings" do
    assert_not pavs(:two).overfull?
  end
end
