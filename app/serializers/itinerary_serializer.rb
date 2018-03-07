class ItinerarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :itinerary  # optional
  attributes :time, :eta

  attribute :address_name do |object|
    object.address.address_text
  end

  attribute :customer_name do |object|
    object.trip.customer.name if object.trip
  end
end