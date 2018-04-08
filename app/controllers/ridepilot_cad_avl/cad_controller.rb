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
      @provider = current_user.current_provider
      latest_locations = GpsLocation.where(provider_id: current_provider_id).where(run_id: params[:cad][:selected_run_ids]).reorder("log_time DESC")
      latest_locations = latest_locations.select("DISTINCT ON(run_id) *").reorder("run_id, log_time DESC")

      latest_locations = latest_locations.to_json

      respond_to do |format|
        format.js { render locals: {latest_locations: latest_locations} }
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
