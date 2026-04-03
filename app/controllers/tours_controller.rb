class ToursController < ApplicationController
  def index
    pavs = Pav.all

    latest_readings = Log.sensor_readings
      .select("DISTINCT ON (pav_id) pav_id, (payload->>'fill_percent')::float AS fill_percent")
      .order("pav_id, occurred_at DESC")

    fill_by_pav = latest_readings.each_with_object({}) do |r, h|
      h[r.pav_id] = r.fill_percent
    end

    @pavs_json = pavs.filter_map { |pav|
      next unless pav.lat && pav.lng
      {
        id: pav.id,
        pav_id: pav.pav_id,
        lat: pav.lat,
        lng: pav.lng,
        name: pav.name,
        waste_type: pav.waste_type,
        fill_percent: fill_by_pav[pav.id]
      }
    }.to_json
  end
end
