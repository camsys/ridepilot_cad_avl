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
  end  
end