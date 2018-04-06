module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"

    before_action :get_date

    def index
      @provider = current_user.current_provider
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
    end

    def reload_runs
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      
      if params[:cad] && params[:cad][:incomplete_runs_only] == 'true'
        @runs = @runs.where(end_odometer: nil)
      end

      respond_to :js
    end

    def update_map_markers
      # Get the runs that match the run ids
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      selected_runs = @runs.where(id: params[:cad][:selected_run_ids])

      # Get the latest gps location for each run
      latest_locations = []
      selected_runs.each do |run|
        latest_location = GpsLocation.where(run_id: run.id).where(provider_id: run.provider_id).reorder("log_time").first
        latest_locations.push(latest_location)
      end

      # Pass locations back to view so they can access the latlng and create the markers
      respond_to do |format|
        format.js { render locals:{latest_locations: latest_locations} }
      end
    end

    private

    def get_date
      @cad_day = if params[:cad] && !params[:cad][:date].blank?
        DateTime.parse params[:cad][:date]
      else
        Date.today
      end
    end

  end
end
