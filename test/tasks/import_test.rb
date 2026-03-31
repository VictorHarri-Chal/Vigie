require "test_helper"
require "rake"

class ImportTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks
    Rake::Task["import:logs"].reenable
    ENV["PAV_LOGS_FILE"] = "test/fixtures/files/pav_logs_sample.json"
  end

  teardown do
    ENV.delete("PAV_LOGS_FILE")
  end

  test "creates pavs and logs from json file" do
    assert_difference ["Pav.count", "Log.count"], 0 do
      # baseline: counters start at whatever is in DB from fixtures
    end

    initial_pavs = Pav.count
    initial_logs = Log.count

    Rake::Task["import:logs"].invoke

    assert_equal initial_pavs + 1, Pav.count
    assert_equal initial_logs + 3, Log.count
  end

  test "deduplicates pav appearing in multiple entries" do
    Rake::Task["import:logs"].invoke
    assert_equal 1, Pav.where(pav_id: "pav-01").count
  end

  test "skips duplicate log_id silently" do
    Rake::Task["import:logs"].invoke
    assert_equal 1, Log.where(log_id: "log-001").count
  end

  test "parses date-only occurred_at on incident" do
    Rake::Task["import:logs"].invoke
    log = Log.find_by(log_id: "log-003")
    assert_not_nil log
    assert_equal "00:00", log.occurred_at.strftime("%H:%M")
  end

  test "is idempotent on second run" do
    Rake::Task["import:logs"].invoke
    Rake::Task["import:logs"].reenable

    assert_no_difference ["Pav.count", "Log.count"] do
      Rake::Task["import:logs"].invoke
    end
  end

  test "imports all three event types" do
    Rake::Task["import:logs"].invoke
    assert Log.sensor_readings.exists?(log_id: "log-001")
    assert Log.badge_deposits.exists?(log_id: "log-002")
    assert Log.incidents.exists?(log_id: "log-003")
  end
end
