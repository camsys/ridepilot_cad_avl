require 'faker'

# Note that every once in a while we may randomly generate two drivers with the
# same name, which will cause spec to fail.
FactoryBot.define do
  factory :driver do
    name { Faker::Lorem.words(3).join(' ') }
    user
    provider
  end
end
