class Log < ApplicationRecord
  belongs_to :pav

  validates :log_id, presence: true, uniqueness: true
  validates :event_type, inclusion: { in: %w[sensor_reading badge_deposit incident] }
  validates :occurred_at, presence: true

  scope :sensor_readings, -> { where(event_type: "sensor_reading") }
  scope :badge_deposits,  -> { where(event_type: "badge_deposit") }
  scope :incidents,       -> { where(event_type: "incident") }
  scope :open_incidents,  -> { incidents.where("payload->>'resolved' = 'false'") }
  scope :recent,          -> { order(occurred_at: :desc) }
end
