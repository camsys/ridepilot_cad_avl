class ItinerarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :itinerary  # optional

  belongs_to :address

  attribute :id, :trip_id, :leg_flag, :status_code, :departure_time, :arrival_time, :finish_time

  attribute :time_seconds do |object|
    (object.time - object.time.beginning_of_day).to_i if object.time
  end

  attribute :eta_seconds do |object|
    (object.eta - object.eta.beginning_of_day).to_i if object.eta
  end

  attribute :trip_notes do |object|
    object.trip.notes if object.trip
  end

  attribute :customer_notes do |object|
    object.trip.customer.try(:private_notes) if object.trip
  end

  attribute :trip_result do |object|
    object.trip.trip_result.try(:name) if object.trip
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

  attribute :phone do |object|
    object.trip.customer.phone_number_1 || object.trip.customer.phone_number_1 if object.trip && object.trip.customer
  end

  attribute :fare do |object|
    trip = object.trip
    if trip 
      fare = trip.fare || trip.provider.fare
      if fare && !fare.is_free? 
        if fare.is_payment?
          fare_amount = trip.fare_amount
          collected_time = trip.fare_collected_time
        else
          fare = trip.donation.try(:amount)
          collected_time = trip.donation.try(:updated_at)
        end
        
        {
          fare_type: fare.fare_type,
          pre_trip: fare.pre_trip,
          amount: fare_amount,
          collected_time: collected_time
        }
      end
    end
  end
end