module RidepilotCadAvl
  class API::V1::RunsController < API::V1::BaseController

    #Gets list of runs
    # GET /
    def index
      @runs = Run.where(date: Date.today, driver: @driver)
      opts = {}
      opts[:include] = [:vehicle]
      render success_response(@runs, opts)
    end

    #Gets manifest of given (or first incomplete) run for today
    # GET /manifest
    def manifest
      unless params[:run_id].blank?
        @run = Run.find_by_id params[:run_id]
      else
        @run = Run.where(date: Date.today, driver: @driver).incomplete.first
      end
      opts = {}
      opts[:include] = [:address]
      render success_response(@run.try(:sorted_itineraries) || [], opts)
    end
  end  
end