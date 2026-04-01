class IncidentsController < ApplicationController
  before_action :set_incident, only: [ :resolve, :reopen ]

  def index
    incidents = case params[:status]
    when "open"     then Log.open_incidents
    when "resolved" then Log.incidents.where("payload->>'resolved' = 'true'")
    else                 Log.incidents
    end

    @pagy, @incidents = pagy(:offset, incidents.includes(:pav).recent, limit: 30)
  end

  def resolve
    @incident.payload = (@incident.payload || {}).merge("resolved" => true)
    @incident.save!
    redirect_back(fallback_location: incidents_path)
  end

  def reopen
    @incident.payload = (@incident.payload || {}).merge("resolved" => false)
    @incident.save!
    redirect_back(fallback_location: incidents_path)
  end

  private

  def set_incident
    @incident = Log.incidents.find(params[:id])
  end
end
