require 'faker'

FactoryBot.define do
  factory :provider do
    name { Faker::Lorem.words(3).join(' ') }
  end
end
