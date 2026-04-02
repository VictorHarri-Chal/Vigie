class Pav < ApplicationRecord
  has_many :logs

  validates :pav_id, presence: true, uniqueness: true
  validates :name, :waste_type, presence: true

  scope :by_waste_type, ->(type) { where(waste_type: type) }

  def current_fill_percent
    logs.sensor_readings.order(occurred_at: :desc).first&.payload&.dig("fill_percent")
  end

  def overfull?
    fill = current_fill_percent
    fill && fill.to_f > 90
  end
end
