module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"

    before_action :get_date

    def index
      @provider = current_provider
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
    end

    def reload_runs
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      
      if params[:cad] && params[:cad][:incomplete_runs_only] == 'true'
        @runs = @runs.where(end_odometer: nil)
      end

      respond_to :js
    end

    def reload_run
      @run = Run.find_by_id(params[:cad][:run_id])
      run_in_progress = @run && @run.date == Date.today && @run.start_odometer && !@run.end_odometer
      
      if run_in_progress
        @vehicle_location = GpsLocation.where(run_id: @run.id).reorder("log_time DESC").first
        @vehicle_location_data = GpsLocationSerializer.new(@vehicle_location).serializable_hash
      end

      respond_to :js
    end

    def vehicle_info
      @vehicle_location = GpsLocation.find_by_id(params[:location_id])
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
