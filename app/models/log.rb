class Log < ApplicationRecord
  belongs_to :pav

  validates :log_id, presence: true, uniqueness: true
  validates :event_type, inclusion: { in: %w[sensor_reading badge_deposit incident] }
  validates :occurred_at, presence: true

  scope :sensor_readings, -> { where(event_type: "sensor_reading") }
  scope :badge_deposits,  -> { where(event_type: "badge_deposit") }
  scope :incidents,       -> { where(event_type: "incident") }
  scope :open_incidents,  -> { incidents.where("(payload->>'resolved') IS DISTINCT FROM 'true'") }
  scope :recent,          -> { order(occurred_at: :desc) }

  ANOMALY_LABELS = {
    "badge_revoked"      => "Badge révoqué",
    "possible_duplicate" => "Doublon possible",
    "unusual_hour"       => "Horaire inhabituel"
  }.freeze

  def resolved?
    payload&.dig("resolved").to_s == "true"
  end

  def description
    payload&.dig("note") || payload&.dig("description") || "Aucune description"
  end

  def anomaly_reasons
    return [] if payload.nil?
    flags = (payload["anomaly_flags"] || []).dup
    flags |= [ "badge_revoked" ] if payload["badge_revoked"]
    flags.filter_map { |f| ANOMALY_LABELS[f] }
  end

  def self.overfull_pav_ids(pav_ids)
    return [] if pav_ids.empty?
    sensor_readings
      .where(pav_id: pav_ids)
      .select("DISTINCT ON (pav_id) pav_id, (payload->>'fill_percent')::float AS fill_percent")
      .order("pav_id, occurred_at DESC")
      .filter_map { |l| l.pav_id if l.fill_percent.to_f > 90 }
  end
end
