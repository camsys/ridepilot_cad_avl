class ItinerarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :itinerary  # optional
  attributes :time
end