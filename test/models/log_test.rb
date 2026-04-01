require "test_helper"

class LogTest < ActiveSupport::TestCase
  # Validations

  test "is invalid without log_id" do
    log = Log.new(event_type: "incident", occurred_at: Time.current, pav: pavs(:one), payload: {})
    assert_not log.valid?
    assert_includes log.errors[:log_id], "can't be blank"
  end

  test "is invalid without occurred_at" do
    log = Log.new(log_id: "log-x", event_type: "incident", pav: pavs(:one), payload: {})
    assert_not log.valid?
    assert_includes log.errors[:occurred_at], "can't be blank"
  end

  test "is invalid with duplicate log_id" do
    log = Log.new(log_id: "log-fixture-001", event_type: "sensor_reading", occurred_at: Time.current, pav: pavs(:one), payload: {})
    assert_not log.valid?
    assert_includes log.errors[:log_id], "has already been taken"
  end

  test "is invalid with unknown event_type" do
    log = Log.new(log_id: "log-x", event_type: "unknown", occurred_at: Time.current, pav: pavs(:one), payload: {})
    assert_not log.valid?
    assert_includes log.errors[:event_type], "is not included in the list"
  end

  # Scopes

  test "sensor_readings returns only sensor readings" do
    assert_includes Log.sensor_readings, logs(:one)
    assert_not_includes Log.sensor_readings, logs(:two)
  end

  test "incidents returns only incidents" do
    assert_includes Log.incidents, logs(:two)
    assert_not_includes Log.incidents, logs(:one)
  end

  test "badge_deposits returns only badge deposits" do
    assert_equal 0, Log.badge_deposits.count
  end

  test "open_incidents returns only unresolved incidents" do
    open = Log.open_incidents
    assert_includes open, logs(:two)
    assert_not_includes open, logs(:three)
  end

  test "recent orders by occurred_at descending" do
    dates = Log.recent.pluck(:occurred_at)
    assert_equal dates.sort.reverse, dates
  end

  # resolved?

  test "resolved? returns true when payload resolved is true" do
    log = Log.new(payload: { "resolved" => true })
    assert log.resolved?
  end

  test "resolved? returns false when payload resolved is false" do
    log = Log.new(payload: { "resolved" => false })
    assert_not log.resolved?
  end

  test "resolved? returns false when resolved key is absent" do
    log = Log.new(payload: {})
    assert_not log.resolved?
  end

  # description

  test "description returns note when present" do
    log = Log.new(payload: { "note" => "Déversement détecté" })
    assert_equal "Déversement détecté", log.description
  end

  test "description falls back to description key" do
    log = Log.new(payload: { "description" => "Problème signalé" })
    assert_equal "Problème signalé", log.description
  end

  test "description returns default string when neither key is present" do
    log = Log.new(payload: { "type" => "overflow" })
    assert_equal "Aucune description", log.description
  end

  # anomaly_reasons

  test "anomaly_reasons returns translated labels for flags" do
    log = Log.new(payload: { "anomaly_flags" => [ "unusual_hour" ] })
    assert_equal [ "Horaire inhabituel" ], log.anomaly_reasons
  end

  test "anomaly_reasons includes badge_revoked when set in payload" do
    log = Log.new(payload: { "anomaly_flags" => [], "badge_revoked" => true })
    assert_equal [ "Badge révoqué" ], log.anomaly_reasons
  end

  test "anomaly_reasons combines flags and badge_revoked without duplicates" do
    log = Log.new(payload: { "anomaly_flags" => [ "unusual_hour", "badge_revoked" ], "badge_revoked" => true })
    assert_equal [ "Horaire inhabituel", "Badge révoqué" ], log.anomaly_reasons
  end

  test "anomaly_reasons returns empty array when no flags" do
    log = Log.new(payload: { "anomaly_flags" => [] })
    assert_equal [], log.anomaly_reasons
  end
end
