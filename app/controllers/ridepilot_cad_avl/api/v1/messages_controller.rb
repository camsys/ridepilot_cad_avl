module RidepilotCadAvl
  class API::V1::MessagesController < API::V1::BaseController
    def send_emergency_alert
      if @driver
        EmergencyAlert.create(provider_id: @driver.provider_id, driver: @driver, sender: @driver.user)
      end

      render success_response({success: true})
    end

    def chats
      opts = {}
      if @driver 
        @messages = RoutineMessage.for_today.where(provider_id: @driver.provider_id, driver: @driver)
      end

      render success_response(@messages, opts)
    end

    def driver_message_templates
      if @driver 
        @templates = DriverMessageTemplate.by_provider(@driver.provider)
      end

      render success_response(@templates, {})
    end

    def send_message
      if @driver
        RoutineMessage.create(provider_id: @driver.provider_id, driver: @driver, sender: @driver.user, body: params[:body])
      end

      render success_response({success: true})
    end
  end
end