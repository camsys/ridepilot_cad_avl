class User < ApplicationRecord
  acts_as_token_authenticatable # token authentication
  include TokenAuthenticationHelpers

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
end
