class PavsController < ApplicationController
  before_action :set_pav, only: [ :show ]

  def index
    @pavs = Pav.all.to_a

    latest_readings = Log.sensor_readings
      .select("DISTINCT ON (pav_id) pav_id, (payload->>'fill_percent')::float AS fill_percent")
      .order("pav_id, occurred_at DESC")

    fill_by_pav = latest_readings.each_with_object({}) do |r, h|
      h[r.pav_id] = r.fill_percent
    end

    @total_pavs = @pavs.size
    @open_incidents = Log.open_incidents.count
    fills = fill_by_pav.values.compact
    @avg_fill = fills.any? ? (fills.sum / fills.size).round : nil

    @pavs_json = @pavs.map { |pav|
      {
        id: pav.id,
        lat: pav.lat,
        lng: pav.lng,
        name: pav.name,
        waste_type: pav.waste_type,
        fill_percent: fill_by_pav[pav.id]
      }
    }.to_json
  end

  def show
    @active_tab = params[:tab].to_i
    @pagy_readings, @sensor_readings = pagy(:offset, @pav.logs.sensor_readings.recent, limit: 15, page_key: "page_r")
    @pagy_deposits, @badge_deposits  = pagy(:offset, @pav.logs.badge_deposits.recent, limit: 15, page_key: "page_d")
    @pagy_incidents, @incidents      = pagy(:offset, @pav.logs.incidents.recent, limit: 15, page_key: "page_i")

    latest = @pav.logs.sensor_readings.maximum(:occurred_at)
    @chart_data = if latest
      @pav.logs.sensor_readings
        .where(occurred_at: (latest - 30.days)..latest)
        .order(:occurred_at)
        .pluck(:occurred_at, Arel.sql("payload->>'fill_percent'"))
        .map { |date, fill| { date: date.strftime("%Y-%m-%d"), fill_percent: fill.to_f } }
        .to_json
    else
      [].to_json
    end
  end

  private

  def set_pav
    @pav = Pav.find(params[:id])
  end
end
