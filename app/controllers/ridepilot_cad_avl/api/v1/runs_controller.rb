module RidepilotCadAvl
  class API::V1::RunsController < API::V1::BaseController

    #Gets list of runs
    # GET /
    def index
      @runs = Run.where(date: Date.today, driver: @driver).default_order
      opts = {}
      opts[:include] = [:vehicle]
      render success_response(@runs, opts)
    end

    # Start run
    def start
      @run = Run.find_by_id(params[:id])
      
      if @run
        @run.driver_notes = params[:driver_notes]
        @run.start_odometer = params[:start_odometer]
        @run.actual_start_time = DateTime.current
        @run.save(validate: false)

        unless params[:inspections].blank?
          params[:inspections].each do |insp|
            run_insp = @run.run_vehicle_inspections.where(vehicle_inspection_id: insp[:id]).first_or_create
            run_insp.checked = insp[:checked]
            run_insp.save(validate: false)
          end
        end

        # start leg completed
        @run.itineraries.run_begin.update_all(status_code: Itinerary::STATUS_COMPLETED)
      end

      render success_response({})
    end

    # End run
    def end
      @run = Run.find_by_id(params[:id])
      
      if @run
        @run.end_odometer = params[:end_odometer]
        @run.actual_end_time = DateTime.current
        @run.save(validate: false)

        # end leg completed
        @run.itineraries.run_end.update_all(status_code: Itinerary::STATUS_COMPLETED)
      end

      render success_response({})
    end

    def inspections
      @run = Run.find_by_id(params[:id])

      render success_response({
        data: @run.try(:vehicle_inspections_as_json) || []
        })
    end
  end  
end