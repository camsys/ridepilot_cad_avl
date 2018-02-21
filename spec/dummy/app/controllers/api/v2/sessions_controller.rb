class API::V2::SessionsController < API::V2::BaseController
  skip_before_action :require_authentication, only: [:create]

  # Signs in an existing user, returning auth token
  # POST /sign_in
  def create
    validate_user

    # Check if any errors were recorded. If not, send a success response.
    if @errors.empty?
      render(success_response(
          message: "User Signed In Successfully", 
          session: session_hash(@user)
        )) and return
    else # If there are any errors, send back a failure response.
      render(fail_response(errors: @errors, status: @fail_status))
    end
    
  end

  # Signs out a user based on username and auth token headers
  # DELETE /sign_out
  def destroy
    if @user && @user.reset_authentication_token
      render(success_response(message: "User #{@user.username} successfully signed out."))
    else
      render(fail_response)
    end
    
  end

  protected

  # Returns the signed in user's username and authentication token
  def session_hash(user)
    {
      username: user.username,
      authentication_token: user.authentication_token
    }
  end
  
  def user_params
    params.require(:user).permit(
      :username,
      :password       
    )
  end

  def validate_user
    @user = User.find_by(username: user_params[:username].downcase)
    @fail_status = 400
    @errors = {}
    
    # Check if a user was found based on the passed username. If so, continue authentication.
    if @user.present?
      # checks if password is incorrect and user is locked, and unlocks if lock is expired
      if @user.valid_for_api_authentication?(user_params[:password])
        @user.ensure_authentication_token
      else
        @fail_status = 401
        @errors[:password] = "Incorrect password for #{@user.username}."     
      end
    else
      @errors[:username] = "Could not find user with username #{user_params[:username]}"
    end
  end
end