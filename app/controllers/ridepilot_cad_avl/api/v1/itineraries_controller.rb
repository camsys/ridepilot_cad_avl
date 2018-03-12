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
    def updateStatus
      @itin = Itinerary.find_by_id(params[:id])
      @itin.update_attribute(status_code: params[:status_code]) if @itin

      opts = {}
      opts[:include] = [:address]
      render success_response(@itin, opts)
    end
  end  
end