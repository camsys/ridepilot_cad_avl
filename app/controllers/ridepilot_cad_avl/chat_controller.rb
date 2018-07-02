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
      @run = Run.find_by_id params[:run_id]
      if @driver
        RoutineMessage.create(provider_id: current_provider_id, run: @run, driver: @driver, sender: current_user, body: params[:message])
      end
    end

    def show
      @message = RoutineMessage.find_by_id params[:id]
    end

    def read 
      @read_receipt = ChatReadReceipt.create(message_id: params[:message_id], read_by_id: params[:read_by_id], run_id: params[:run_id])

      render json: {}
    end
  end
end
