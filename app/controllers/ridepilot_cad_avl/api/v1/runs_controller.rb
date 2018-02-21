module RidepilotCadAvl
  class API::V1::RunsController < API::V1::BaseController

    #Gets list of runs
    # GET /
    def index
      @runs = Run.where(date: Date.today, driver: @driver)
      render success_response(@runs)
    end

    #Gets manifest of active (or first incomplete) run for today
    # GET /manifest
    def manifest
      @run = Run.where(date: Date.today, driver: @driver).incomplete.first
      render success_response(@run.try(:sorted_itineraries))
    end
  end  
end