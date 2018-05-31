module RidepilotCadAvl
  class ChatController < ::ApplicationController
    layout "ridepilot_cad_avl/chat"

    def show
      @run = Run.find_by_id params[:run_id]
      if @run 
        @messages = RoutineMessage.for_today.where(driver_id: @run.driver_id).order(created_at: :desc)
      end
    end
  end
end
