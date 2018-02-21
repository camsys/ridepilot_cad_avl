module TokenAuthenticationHelpers
  
  def reset_authentication_token
    update_attributes(authentication_token: nil)
    ensure_authentication_token
    authentication_token.present?
  end
  
  # Checks whether or not an API user is valid for authentication.
  def valid_for_api_authentication?(password=nil)
    # the valid_for_authentication? method is defined in Devise's models/authenticatable.rb
    valid_for_authentication? do
      # check if password is correct
      valid_password?(password)
    end
  end
  
end
