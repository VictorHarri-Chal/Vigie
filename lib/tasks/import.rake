namespace :import do
  desc "Import PAV logs from pas_logs.json"
  task logs: :environment do
    file_path = Rails.root.join(ENV.fetch("PAV_LOGS_FILE", "pav_logs.json"))
    abort "File not found: #{file_path}" unless File.exist?(file_path)

    data = JSON.parse(File.read(file_path))
    imported = 0
    skipped = 0
    invalid = 0

    data.each do |entry|
      pav_data = entry["pav"]
      pav = Pav.find_or_initialize_by(pav_id: pav_data["id"])
      pav.assign_attributes(
        name: pav_data["name"],
        address: pav_data["address"],
        city: pav_data["city"],
        zip: pav_data["zip"],
        lat: pav_data["lat"],
        lng: pav_data["lng"],
        waste_type: pav_data["waste_type"],
        capacity_liters: pav_data["capacity_liters"]
      )
      pav.save! if pav.changed?

      occurred_at = parse_date(entry["occurred_at"])
      unless occurred_at
        invalid += 1
        next
      end

      log = Log.find_or_initialize_by(log_id: entry["id"])
      if log.persisted?
        skipped += 1
        next
      end

      log.assign_attributes(
        event_type: entry["event_type"],
        occurred_at: occurred_at,
        payload: entry["payload"],
        imported_at: Time.current,
        pav: pav
      )

      if log.save
        imported += 1
      else
        invalid += 1
        puts "  Invalid log #{entry['id']}: #{log.errors.full_messages.join(', ')}"
      end
    end

    puts "Import complete — #{imported} imported, #{skipped} skipped, #{invalid} invalid"
  end

  def parse_date(raw)
    DateTime.parse(raw)
  rescue ArgumentError, TypeError
    begin
      Date.parse(raw).to_datetime
    rescue ArgumentError, TypeError
      nil
    end
  end
end
