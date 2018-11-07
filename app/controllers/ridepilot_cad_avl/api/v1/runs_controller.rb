module RidepilotCadAvl
  class API::V1::RunsController < API::V1::BaseController

    #Gets list of runs
    # GET /
    def index
      get_runs
      opts = {}
      opts[:include] = [:vehicle]
      render success_response(@runs, opts)
    end

    def show
      @run = Run.find_by_id(params[:id])
      opts = {}
      opts[:include] = [:vehicle]
      render success_response(@run, opts)
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
        @run.update_column(:from_garage_address_id, addr.id)
      end
      
      render success_response({})
    end

    def update_to_address
      @run = Run.find_by_id(params[:id])
      if @run
        addr = parse_address
        addr.save
        @run.update_column(:to_garage_address_id, addr.id)
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
        get_runs
        active_run = @runs.where.not(start_odometer: nil)
          .where(end_odometer: nil)
          .default_order.first
        
        if active_run 
          public_itins = active_run.public_itineraries
          active_public_itin = public_itins.non_finished.first
          active_itin = active_public_itin.try(:itinerary)
          idx = public_itins.index(active_public_itin)
          next_itin = public_itins[idx + 1].try(:itinerary) if idx 

          last_read_message_id = ChatReadReceipt.for_today.where(read_by_id: current_user.try(:id), run_id: active_run.id).reorder(created_at: :desc).first.try(:message_id)
          last_message_id = RoutineMessage.for_today.where.not(sender_id: current_user.try(:id)).where(run_id: active_run.id).reorder(created_at: :desc).first.try(:id)

          has_unread_chat = last_read_message_id != last_message_id
        end
      end

      itin_opts = {}
      itin_opts[:include] = [:address]

      provider = @driver.provider
      render success_response({
        provider_id: provider.try(:id),
        has_unread_chat: has_unread_chat,
        timezone: Time.zone.name,
        gps_interval_seconds: ApplicationSetting['cad_avl.gps_interval_seconds'] || 10,
        active_run: active_run ? RunSerializer.new(active_run).serializable_hash : nil,
        active_itin: active_itin ? ItinerarySerializer.new(active_itin, itin_opts).serializable_hash : nil,
        next_itin: next_itin ? ItinerarySerializer.new(next_itin, itin_opts).serializable_hash : nil,
        timezone_offset: (DateTime.current.utc_offset / 3600),
        map_center_lat: (provider && provider.viewport_center ? provider.viewport_center.y : GOOGLE_MAP_DEFAULTS[:viewport][:center_lat]),
        map_center_lng: (provider && provider.viewport_center ? provider.viewport_center.x : GOOGLE_MAP_DEFAULTS[:viewport][:center_lng]),
        map_zoom: (provider && provider.viewport_zoom || GOOGLE_MAP_DEFAULTS[:viewport][:zoom] || 10)
        })
    end

    def manifest_published_at
      @run = Run.find_by_id(params[:id])
      render success_response({
        manifest_published_at: @run.try(:manifest_published_at)
        })
    end

    private

    def get_runs
      @runs = Run.where(date: Date.today, driver: @driver).default_order.joins(:public_itineraries).group('runs.id')
    end

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