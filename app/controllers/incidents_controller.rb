class IncidentsController < ApplicationController
  before_action :set_incident, only: [ :resolve, :reopen, :update_note ]

  def index
    @pavs = Pav.order(:name)

    incidents = case params[:status]
    when "open"     then Log.open_incidents
    when "resolved" then Log.incidents.where("payload->>'resolved' = 'true'")
    else                 Log.incidents
    end

    incidents = incidents.where(pav_id: params[:pav_id]) if params[:pav_id].present?
    incidents = incidents.where("occurred_at >= ?", Date.parse(params[:from_date])) if params[:from_date].present?
    incidents = incidents.where("occurred_at <= ?", Date.parse(params[:to_date]).end_of_day) if params[:to_date].present?

    respond_to do |format|
      format.html do
        @pagy, @incidents = pagy(:offset, incidents.includes(:pav).recent, limit: 9)
      end
      format.csv do
        rows = incidents.includes(:pav).recent
        csv = CSV.generate(headers: true) do |csv|
          csv << [ "PAV", "Identifiant", "Date", "Description", "Statut" ]
          rows.each do |incident|
            csv << [
              incident.pav.name,
              incident.pav.pav_id,
              incident.occurred_at.strftime("%d/%m/%Y"),
              incident.description,
              incident.resolved? ? "Résolu" : "Ouvert"
            ]
          end
        end
        send_data csv, filename: "incidents-#{Date.today}.csv", type: "text/csv"
      end
    end
  end

  def update_note
    @incident.payload = (@incident.payload || {}).merge("note" => params[:note].to_s.strip)
    @incident.save!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "note-#{@incident.id}",
          partial: "incidents/note",
          locals: { incident: @incident }
        )
      end
      format.html { redirect_to incidents_path }
    end
  end

  def resolve
    @incident.payload = (@incident.payload || {}).merge("resolved" => true)
    @incident.save!
    redirect_to request.referer&.include?("/incidents") ? incidents_path : pav_path(@incident.pav, tab: 4)
  end

  def reopen
    @incident.payload = (@incident.payload || {}).merge("resolved" => false)
    @incident.save!
    redirect_to request.referer&.include?("/incidents") ? incidents_path : pav_path(@incident.pav, tab: 4)
  end

  private

  def set_incident
    @incident = Log.incidents.find(params[:id])
  end
end
