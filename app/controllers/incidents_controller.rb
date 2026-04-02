class IncidentsController < ApplicationController
  before_action :set_incident, only: [ :resolve, :reopen ]

  def index
    incidents = case params[:status]
    when "open"     then Log.open_incidents
    when "resolved" then Log.incidents.where("payload->>'resolved' = 'true'")
    else                 Log.incidents
    end

    respond_to do |format|
      format.html do
        @pagy, @incidents = pagy(:offset, incidents.includes(:pav).recent, limit: 30)
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
