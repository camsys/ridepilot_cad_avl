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

    private

    def itin_params
      params.require(:itinerary).permit(:status_code, :departure_time, :arrival_time, :finish_time)
    end
  end  
end