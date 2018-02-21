require 'faker'

FactoryBot.define do
  factory :user do
    first_name "Test"
    last_name "User"
    sequence(:username)  {|n| "fakeuser#{n}" }
    email { Faker::Internet.email }
    password 'Password#1'
    password_confirmation {|u| u.password}
    sequence(:authentication_token)  {|n| "token#{n}" }
  end
end
