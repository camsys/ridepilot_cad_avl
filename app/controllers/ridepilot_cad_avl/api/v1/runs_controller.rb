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
        current_time = DateTime.current
        @run.actual_start_time = current_time
        @run.save(validate: false)

        unless params[:inspections].blank?
          params[:inspections].each do |insp|
            run_insp = @run.run_vehicle_inspections.where(vehicle_inspection_id: insp[:id]).first_or_create
            run_insp.checked = insp[:checked]
            run_insp.save(validate: false)
          end
        end

        # start leg completed
        @run.itineraries.run_begin.update_all(status_code: Itinerary::STATUS_COMPLETED, finish_time: current_time)
      end

      render success_response({})
    end

    # End run
    def end
      @run = Run.find_by_id(params[:id])
      
      if @run
        @run.end_odometer = params[:end_odometer]
        current_time = DateTime.current
        @run.actual_end_time = current_time
        @run.save(validate: false)

        # end leg completed
        @run.itineraries.run_end.update_all(status_code: Itinerary::STATUS_COMPLETED, finish_time: current_time)
      end

      render success_response({})
    end

    def update_from_address
      @run = Run.find_by_id(params[:id])
      if @run
        addr = parse_address
        addr.save
        @run.from_garage_address = addr
        @run.save(validate: false)
      end
      
      render success_response({})
    end

    def update_to_address
      @run = Run.find_by_id(params[:id])
      if @run
        addr = parse_address
        addr.save
        @run.to_garage_address = addr
        @run.save(validate: false)
      end

      render success_response({})
    end

    def inspections
      @run = Run.find_by_id(params[:id])

      render success_response({
        data: @run.try(:vehicle_inspections_as_json) || []
        })
    end

    # find active run and active itin
    def driver_run_data
      if @driver 
        active_run = Run.where(date: Date.today, driver: @driver)
          .where.not(start_odometer: nil)
          .where(end_odometer: nil)
          .default_order.first
        
        if active_run 
          public_itins = active_run.public_itineraries
          active_public_itin = public_itins.non_finished.first
          active_itin = active_public_itin.try(:itinerary)
          idx = public_itins.index(active_public_itin)
          next_itin = public_itins[idx + 1].try(:itinerary) if idx 
        end
      end

      itin_opts = {}
      itin_opts[:include] = [:address]

      render success_response({
        timezone: Time.zone.name,
        active_run: active_run ? RunSerializer.new(active_run).serializable_hash : nil,
        active_itin: active_itin ? ItinerarySerializer.new(active_itin, itin_opts).serializable_hash : nil,
        next_itin: next_itin ? ItinerarySerializer.new(next_itin, itin_opts).serializable_hash : nil
        })
    end

    private

    def parse_address
      address = GarageAddress.new(address_params)
      if params[:address][:longitude] && params[:address][:latitude]
        address.the_geom = Address.compute_geom(params[:address][:latitude], params[:address][:longitude])
      end

      address
    end

    def address_params
      params.required(:address).permit(:address, :city, :state, :zip)
    end
  end  
end