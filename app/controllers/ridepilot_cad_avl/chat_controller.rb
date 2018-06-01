module RidepilotCadAvl
  class ChatController < ::ApplicationController
    layout "ridepilot_cad_avl/chat"

    def index
      @run = Run.find_by_id params[:run_id]
      if @run 
        @driver = @run.driver
        @messages = RoutineMessage.for_today.where(driver_id: @run.driver_id).order(created_at: :asc)
      end
    end

    def create
      @driver = Driver.find_by_id params[:driver_id]
      if @driver
        RoutineMessage.create(provider_id: current_provider_id, driver: @driver, sender: current_user, body: params[:message])
      end
    end

    def show
      @message = RoutineMessage.find_by_id params[:id]
    end
  end
end
