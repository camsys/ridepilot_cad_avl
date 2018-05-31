module RidepilotCadAvl
  class API::V1::MessagesController < API::V1::BaseController
    def create_emergency_alert
      if @driver
        EmergencyAlert.create(provider_id: @driver.provider_id, driver: @driver, sender: @driver.user)
      end

      render success_response({success: true})
    end

    def create_routine_message
      if @driver
        RoutineMessage.create(provider_id: @driver.provider_id, driver: @driver, sender: @driver.user, body: params[:message])
      end

      render success_response({success: true})
    end
  end
end