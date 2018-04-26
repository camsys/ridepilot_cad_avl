module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"

    before_action :get_date

    def index
      @provider = current_provider
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")

      @is_today = @cad_day == Date.today
      @is_today_or_past = @cad_day <= Date.today
      @is_today_or_future = @cad_day >= Date.today
    end

    def reload_runs
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      
      @incomplete_only = params[:cad] && params[:cad][:incomplete_runs_only] == 'true'
      if @incomplete_only
        @runs = @runs.where(end_odometer: nil)
      end

      respond_to :js
    end

    def reload_run
      @run = Run.find_by_id(params[:cad][:run_id])
      if @run 
        @run_ids = [@run.id]
        # exclude complete run if showing only incomplete ones
        unless params[:cad][:incomplete_runs_only] == 'true' && @run.end_odometer
          @run_in_progress = @run.date == Date.today && @run.start_odometer && !@run.end_odometer
          
          if @run_in_progress
            @vehicle_location = GpsLocation.where(run_id: @run.id).reorder("log_time DESC").first
            @vehicle_location_data = GpsLocationSerializer.new(@vehicle_location).serializable_hash
          end

          prepare_run_stops_data(@run.id) if params[:options][:stops] == 'true'
          prepare_prior_path_data if params[:options][:prior_path] == 'true'
          prepare_upcoming_path_data if params[:options][:upcoming_path] == 'true'
        end
      end

      respond_to :js
    end

    def load_run_stops
      @run_ids = params[:run_ids].split(',') unless params[:run_ids].blank?
      prepare_run_stops_data(@run_ids)
    end

    def load_prior_path
      @run = Run.find_by_id(params[:cad][:run_id])
      prepare_prior_path_data
    end

    def load_upcoming_path
      @run = Run.find_by_id(params[:cad][:run_id])
      @run_in_progress = (@run.date == Date.today && @run.start_odometer && !@run.end_odometer) if @run
      prepare_upcoming_path_data
    end

    def vehicle_info
      @vehicle_location = GpsLocation.find_by_id(params[:location_id])
    end

    def past_location_info
      @past_location = GpsLocation.find_by_id(params[:location_id])
    end

    def stop_info
      @itin = Itinerary.find_by_id(params[:itinerary_id])
    end

    private

    def get_date
      @cad_day = if params[:cad] && !params[:cad][:date].blank?
        DateTime.parse params[:cad][:date]
      else
        Date.today
      end
    end

    def prepare_run_stops_data(run_ids)
      @itins_data = Run.where(id: run_ids).joins(itineraries: :address).pluck(
        "itineraries.id",
        "ST_Y(addresses.the_geom::geometry) as longitude",
        "ST_X(addresses.the_geom::geometry) as latitude",
        :run_id, 
        :leg_flag, 
        :status_code
        )
    end

    def prepare_prior_path_data
      if @run
        new_locations = GpsLocation.where(run_id: @run.id)
        unless params[:cad][:last_log_time].blank?
          last_log_time = DateTime.parse params[:cad][:last_log_time]
          new_locations = new_locations.where("log_time > ?", last_log_time)
        end
        @prior_locations = new_locations.pluck(:latitude, :longitude)
      end
    end

    def prepare_upcoming_path_data
      if @run
        # get start location   
        if @run_in_progress
          @vehicle_location = GpsLocation.where(run_id: @run.id).reorder("log_time DESC").first
          if @vehicle_location
            @start_latlng = [@vehicle_location.latitude, @vehicle_location.longitude]
            current_itin_id = @vehicle_location.itinerary_id
          end
        end

        itins = @run.sorted_itineraries
        
        # get destination location
        last_itin = itins.last
        @end_latlng = get_itin_address_latlng(last_itin)
        if !@end_latlng && itins.length > 2
          second_last_itin = itins[itins.length - 2]
          @end_latlng = get_itin_address_latlng(second_last_itin)
        end

        # get waypoints
        @waypoint_latlngs = []
        current_itin_found = false
        itins.each_with_index do |itin, idx|
          if !@start_latlng 
            @start_latlng = get_itin_address_latlng(itin)
          end
          current_itin_found = true if current_itin_id == itin.id
          if !current_itin_id || current_itin_found
            latlng = get_itin_address_latlng(itin)
            @waypoint_latlngs << latlng if latlng
          end
        end
      end
    end

    def get_itin_address_latlng(itin)
      if itin && itin.address && itin.address.geocoded?
        [itin.address.latitude, itin.address.longitude]
      end
    end

  end
end
