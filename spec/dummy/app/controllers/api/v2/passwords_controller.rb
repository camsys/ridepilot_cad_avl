class API::V2::PasswordsController < API::V2::BaseController
  skip_before_action :require_authentication

  # Request to send password reset instructions to user email
  # POST /reset_password
  def reset
    username = user_params[:username].try(:downcase) unless user_params.blank?
    @user = User.find_by(username: username)
    
    # Send a failure response if no account exists with the given email
    unless @user.present?
      render(fail_response(message: "User #{username} does not exist")) and return
    end
  
    @user.send_reset_password_instructions
    
    render(success_response(message: "Password reset email sent to #{@user.email}."))
  end

  protected
  
  def user_params
    if params[:user]
      params.require(:user).permit(
        :username     
      )
    end
  end
end