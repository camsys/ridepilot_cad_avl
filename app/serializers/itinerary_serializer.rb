class ItinerarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :itinerary  # optional

  belongs_to :address

  attribute :id, :leg_flag

  attribute :time_seconds do |object|
    (object.time - object.time.beginning_of_day).to_i if object.time
  end

  attribute :eta_seconds do |object|
    (object.eta - object.eta.beginning_of_day).to_i if object.eta
  end

  attribute :trip_notes do |object|
    object.trip.notes if object.trip
  end

  attribute :trip_address_notes do |object|
    if object.trip
      if object.is_pickup?
        object.trip.pickup_address_notes
      else
        object.trip.dropoff_address_notes
      end
    end
  end

  attribute :customer_name do |object|
    object.trip.customer.name if object.trip
  end
end