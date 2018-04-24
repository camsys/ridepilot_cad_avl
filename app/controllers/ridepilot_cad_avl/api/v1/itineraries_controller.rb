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
      render success_response(@run.try(:sorted_itineraries) || [], opts)
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
      @itin = Itinerary.find_by_id(params[:id])
      if @itin
        run = @itin.run 
        provider = run.provider 
        log_time = DateTime.now
        gps_location = GpsLocation.new(gps_location_params)
        gps_location.provider = provider
        gps_location.log_time = log_time
        gps_location.run = run 
        gps_location.itinerary_id = @itin.id 
        gps_location.save
      end

      render success_response({})
    end

    def update_eta
       @itin = Itinerary.find_by_id(params[:id])
      if @itin
        run = @itin.run 
        old_eta = @itin.eta.try(:to_datetime)
        new_eta = Time.parse(params[:eta]) unless params[:eta].blank?
        eta_diff_seconds = (new_eta - old_eta).to_i if new_eta && old_eta
        @itin.eta = new_eta 
        @itin.save(validate: false)

        if eta_diff_seconds && eta_diff_seconds != 0
          itins = run.sorted_itineraries
          itin_index = itins.index(@itin)
          if itin_index
            itins[itin_index+1..-1].each do |itin|
              if itin.eta 
                itin.eta = itin.eta + (eta_diff_seconds).seconds 
                itin.save(validate: false)
              end
            end
          end
        end
        
      end

      render success_response({})
    end

    private

    def itin_params
      params.require(:itinerary).permit(:status_code, :departure_time, :arrival_time, :finish_time)
    end

    def gps_location_params
      params.require(:gps_location).permit(:latitude, :longitude, :bearing, :speed, :accuracy)
    end
  end  
end