module RidepilotCadAvl
  class API::V1::ItinerariesController < API::V1::BaseController

    #Gets list of itineraries
    # GET /manifest
    def index
      unless params[:run_id].blank?
        @run = Run.find_by_id params[:run_id]
      else
        @run = Run.where(date: Date.today, driver: @driver).incomplete.first
      end
      opts = {}
      opts[:include] = [:address]
      #itin_ids = @run.public_itineraries.pluck(:itinerary_id)
      itins = Itinerary.unscoped.joins(:public_itinerary).where(public_itineraries: {run_id: @run.id}).order("public_itineraries.sequence")
      exclude_leg_ids = itins.dropoff.joins(trip: :trip_result).where(trip_results: {code: TripResult::NON_DISPATCHABLE_CODES}).pluck(:id).uniq
      itins = itins.where.not(id: exclude_leg_ids)
      render success_response(itins, opts)
    end

    # Gets one itinerary
    # GET /itinerary
    def show
      @itin = Itinerary.find_by_id(params[:id])
      
      opts = {}
      opts[:include] = [:address]
      render success_response(@itin, opts)
    end

    # Set itinerary status_code
    # PUT /updateItinStatus
    def update
      @itin = Itinerary.find_by_id(params[:id])

      @itin.update_attributes(itin_params) if @itin

      opts = {}
      opts[:include] = [:address]
      render success_response(@itin, opts)
    end

    # Depart
    def depart
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        @itin.status_code = Itinerary::STATUS_IN_PROGRESS
        @itin.departure_time = DateTime.current
        @itin.save(validate: false)
      end
      
      render success_response({})
    end

    # Arrive
    def arrive
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        @itin.arrival_time = DateTime.current
        @itin.save(validate: false)
      end
      
      render success_response({})
    end

    def pickup
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        @itin.status_code = Itinerary::STATUS_COMPLETED
        @itin.finish_time = DateTime.current
        @itin.save(validate: false)
      end
      
      render success_response({})
    end

    def dropoff
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        @itin.status_code = Itinerary::STATUS_COMPLETED
        @itin.finish_time = DateTime.current
        @itin.save(validate: false)

        trip = @itin.trip 
        if trip 
          trip.trip_result = TripResult.find_by_code('COMP')
          trip.save(validate: false)
        end
      end
      
      render success_response({})
    end

    def noshow
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        @itin.status_code = Itinerary::STATUS_OTHER
        @itin.finish_time = DateTime.current
        @itin.save(validate: false)

        trip = @itin.trip 
        if trip 
          trip.trip_result = TripResult.find_by_code('NS')
          trip.save(validate: false)
        end
      end
      
      render success_response({})
    end

    def undo
      @itin = Itinerary.find_by_id(params[:id])
      if @itin 
        fare = @itin.fare
        trip = @itin.trip

        if fare && trip && @itin.is_pickup? && @itin.finish_time && trip.fare_collected_time
          trip.fare_collected_time = nil
        elsif fare && @itin.is_pickup? && @itin.finish_time && !trip.fare_collected_time
          @itin.finish_time = nil 
          @itin.status_code = Itinerary::STATUS_IN_PROGRESS
          revert_trip_result = true
        elsif fare && @itin.is_dropoff? && !@itin.finish_time && trip.fare_collected_time
          trip.fare_collected_time = nil
        elsif fare && @itin.is_dropoff? && !@itin.finish_time && @itin.arrival_time && !trip.fare_collected_time
          @itin.arrival_time = nil
        else
          if @itin.finish_time
            @itin.finish_time = nil 
            @itin.status_code = Itinerary::STATUS_IN_PROGRESS
            revert_trip_result = true
          else
            if @itin.arrival_time
              @itin.arrival_time = nil 
            elsif @itin.departure_time
              @itin.departure_time = nil
              @itin.status_code = Itinerary::STATUS_PENDING
            end
          end
        end
        
        @itin.save(validate: false) if @itin.changed?

        if trip
          trip.trip_result = nil if revert_trip_result
          trip.save(validate: false) if trip.changed?
        end
      end
      
      render success_response({})
    end

    def track_location
      provider_id = @driver.provider_id
      @itin = Itinerary.find_by_id(params[:id])
      if @itin
        gps_location = GpsLocation.new(gps_location_params)
        gps_location.provider_id = provider_id
        gps_location.save
      end

      render success_response({})
    end

    def batch_sync_locations
      provider_id = @driver.provider_id
      location_params = params[:gps_locations]
      unless location_params.blank?
        location_params.each do |loc_params|
          gps_location = GpsLocation.new(gps_location_params(loc_params))
          gps_location.provider_id = provider_id
          gps_location.save
        end
      end

      render success_response({})
    end

    def update_eta
      EtaUpdateWorker.perform_async(params[:id], params[:eta])
      render success_response({})
    end

    private

    def itin_params
      params.require(:itinerary).permit(:status_code, :departure_time, :arrival_time, :finish_time)
    end

    def gps_location_params(loc_params = nil)
      loc_params = params.require(:gps_location) unless loc_params
      loc_params.permit(:latitude, :longitude, :bearing, :speed, :accuracy, :log_time, :run_id, :itinerary_id)
    end
  end  
end