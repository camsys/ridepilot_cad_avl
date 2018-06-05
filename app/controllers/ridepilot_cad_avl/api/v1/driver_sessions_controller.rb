module RidepilotCadAvl
  class API::V1::DriverSessionsController < ::API::V2::SessionsController
    skip_before_action :require_authentication, only: [:create]

    # Signs in an existing driver, returning auth token
    # POST /driver_sign_in
    def create
      validate_user

      if @errors.empty?
        @driver = Driver.find_by(user_id: @user.id)
        unless @driver.present?
          @fail_status = 401
          @errors[:username] = "User is not a driver." 
        end
      end

      # Check if any errors were recorded. If not, send a success response.
      if @errors.empty?
        render(success_response(
            message: "Driver Signed In Successfully", 
            session: session_hash
          )) and return
      else # If there are any errors, send back a failure response.
        render(fail_response(errors: @errors, status: @fail_status))
      end
      
    end

    private

    # Returns the signed in user's username and authentication token
  def session_hash
    {
      id: @user.id,
      driver_id: @driver.id,
      provider_id: @driver.provider_id,
      name: @user.name,
      username: @user.username,
      authentication_token: @user.authentication_token
    }
  end

  end
end