module RidepilotCadAvl
  class API::V1::RunsController < API::V1::BaseController

    #Gets list of runs
    # GET /
    def index
      @runs = Run.where(date: Date.today, driver: @driver)
      render success_response(@runs)
    end
  end  
end