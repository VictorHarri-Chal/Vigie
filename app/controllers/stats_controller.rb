class StatsController < ApplicationController
  CHART_COLORS   = %w[#60a5fa #34d399 #facc15 #f87171 #a78bfa #fb923c #e879f9].freeze
  FRENCH_MONTHS  = %w[janv. févr. mars avr. mai juin juil. août sept. oct. nov. déc.].freeze

  def index
    reference = Log.maximum(:occurred_at) || Time.current

    fill_by_day = Log.sensor_readings
      .where(occurred_at: (reference - 30.days)..reference)
      .group("DATE(occurred_at)")
      .average("(payload->>'fill_percent')::float")
      .sort.to_h

    by_waste = Log.incidents
      .joins(:pav)
      .group("pavs.waste_type")
      .count

    incidents_by_month = Log.incidents
      .where(occurred_at: (reference - 6.months)..reference)
      .group("TO_CHAR(occurred_at, 'YYYY-MM')")
      .count
      .sort.to_h

    top_active = Log.where.not(event_type: "incident")
      .group(:pav_id).count.sort_by { |_, v| -v }.first(5)
    active_pavs = Pav.where(id: top_active.map(&:first)).index_by(&:id)

    top_problematic = Log.open_incidents
      .group(:pav_id).count.sort_by { |_, v| -v }.first(5)
    problem_pavs = Pav.where(id: top_problematic.map(&:first)).index_by(&:id)

    @fill_chart        = fill_chart_config(fill_by_day)
    @waste_chart       = waste_chart_config(by_waste)
    @timeline_chart    = monthly_incidents_config(incidents_by_month)
    @active_chart      = pav_bar_config(top_active, active_pavs, "Événements")
    @problematic_chart = pav_bar_config(top_problematic, problem_pavs, "Incidents ouverts")
  end

  private

  def fill_chart_config(fill_by_day)
    {
      type: "line",
      data: {
        labels: fill_by_day.keys.map { |d| format_day(d) },
        datasets: [{
          data: fill_by_day.values.map { |v| v.to_f.round(1) },
          borderColor: "#facc15",
          backgroundColor: "rgba(250,204,21,0.06)",
          tension: 0.4,
          fill: true,
          pointRadius: 2,
          pointBackgroundColor: "#facc15",
          borderWidth: 2
        }]
      },
      options: scale_options(y_max: 100)
    }.to_json
  end

  def waste_chart_config(by_waste)
    {
      type: "doughnut",
      data: {
        labels: by_waste.keys.map { |k| k&.humanize || "Inconnu" },
        datasets: [{
          data: by_waste.values,
          backgroundColor: CHART_COLORS.first(by_waste.size),
          borderWidth: 0,
          hoverOffset: 6
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: "right",
            labels: { color: "#9ca3af", boxWidth: 12, padding: 16, font: { size: 11 } }
          }
        }
      }
    }.to_json
  end

  def monthly_incidents_config(incidents_by_month)
    {
      type: "bar",
      data: {
        labels: incidents_by_month.keys.map { |m| format_month(m) },
        datasets: [{
          data: incidents_by_month.values,
          backgroundColor: "rgba(248,113,113,0.75)",
          borderRadius: 4,
          borderWidth: 0
        }]
      },
      options: scale_options
    }.to_json
  end

  def pav_bar_config(pav_counts, pav_map, label)
    {
      type: "bar",
      data: {
        labels: pav_counts.map { |id, _| pav_map[id]&.name || "—" },
        datasets: [{
          label: label,
          data: pav_counts.map(&:last),
          backgroundColor: "rgba(250,204,21,0.75)",
          borderRadius: 4,
          borderWidth: 0
        }]
      },
      options: {
        indexAxis: "y",
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
          x: { ticks: { color: "#6b7280", precision: 0 }, grid: { color: "rgba(255,255,255,0.04)" } },
          y: { ticks: { color: "#9ca3af" }, grid: { display: false } }
        }
      }
    }.to_json
  end

  def format_day(date)
    "#{date.day} #{FRENCH_MONTHS[date.month - 1]}"
  end

  def format_month(yyyymm)
    date = Date.parse("#{yyyymm}-01")
    "#{FRENCH_MONTHS[date.month - 1]} #{date.strftime("%y")}"
  end

  def scale_options(y_max: nil, show_legend: false)
    y_axis = { min: 0, ticks: { color: "#6b7280", precision: 0 }, grid: { color: "rgba(255,255,255,0.04)" } }
    y_axis[:max] = y_max if y_max

    {
      responsive: true,
      plugins: {
        legend: show_legend ? { labels: { color: "#9ca3af", boxWidth: 12 } } : { display: false }
      },
      scales: {
        x: { ticks: { color: "#6b7280", maxTicksLimit: 10 }, grid: { color: "rgba(255,255,255,0.04)" } },
        y: y_axis
      }
    }
  end
end
