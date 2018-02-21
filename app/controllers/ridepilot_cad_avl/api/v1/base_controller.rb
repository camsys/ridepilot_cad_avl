module RidepilotCadAvl
  class API::V1::BaseController < ::API::V2::BaseController
    before_action :driver_required

    attr_reader :driver

    protected

    # Actions to take after successfully authenticated a user token.
    # This is run automatically on successful token authentication
    def after_successful_token_authentication
      set_driver
    end

    def set_driver 
      @driver = Driver.find_by(user_id: current_user.try(:id))
    end

    # Renders a 401 failure response if driver authentication was not successful
    def driver_required
      render_failed_driver_auth_response unless @driver.present? # render a 401 error
    end

    # Renders a failed driver auth response
    def render_failed_driver_auth_response
      render status: 401,
        json: json_response(:fail, data: {user: "User is not a driver."})
    end

  end
end