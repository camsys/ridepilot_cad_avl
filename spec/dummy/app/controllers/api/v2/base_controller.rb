class API::V2::BaseController < API::ApiController
  include JsonResponseHelper::ApiErrorCatcher # Catches 500 errors and sends back JSON with headers.
  before_action :require_authentication

  def touch_session
    render status: 200,
      json: {}
  end

  protected

  # Returns a hash of authentication headers, or an empty hash if not present
  def auth_headers
    {
      username: request.headers["X-USER-USERNAME"], 
      authentication_token: request.headers["X-USER-TOKEN"]
    }
  end

  # Renders a 401 failure response if authentication was not successful
  def require_authentication
    render_failed_auth_response unless authentication_successful? # render a 401 error
  end

  # Renders a failed user auth response
  def render_failed_auth_response
    render status: 401,
      json: json_response(:fail, data: {user: "Valid username and token must be present."})
  end

  # Returns true if authentication has successfully completed
  def authentication_successful?
    current_user.present?
  end

  #  Renders a successful response, passing along a given object as data
  def success_response(data={}, opts={})
    status = opts.delete(:status) || 200 # Status code is 200 by default
    
    {
      status: status,
      json: {
        status: "success",
        data: data
      }
    }
  end

  # Renders a failure response (client error), passing along a given object as data
  def fail_response(data={})
    status = data.delete(:status) || 400
    {
      status: status,
      json: {
        status: "fail",
        data: data
      }
    }
  end
  
  # Renders an error response (server error), passing along a given message
  def error_response(opts={}, message="Server Error")
    status = opts.delete(:status) || 500
    {
      status: status,
      json: {
        status: "error",
        message: message
      }
    }
  end

end