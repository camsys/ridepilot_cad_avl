class RunSerializer
  include FastJsonapi::ObjectSerializer
  set_type :run  # optional
  attributes :name, :complete

  belongs_to :vehicle

  attribute :scheduled_start_time_seconds do |object|
    (object.scheduled_start_time - object.scheduled_start_time.beginning_of_day).to_i if object.scheduled_start_time
  end

  attribute :scheduled_end_time_seconds do |object|
    (object.scheduled_end_time - object.scheduled_end_time.beginning_of_day).to_i if object.scheduled_end_time
  end

  attribute :trips_count do |object|
    object.trips.size
  end

  attribute :status_code do |object|
    if object.end_odometer.present?
      2
    elsif object.start_odometer.present?
      1
    else
      0
    end
  end

  attribute :status do |object|
    if object.end_odometer.present?
      "Completed"
    elsif object.start_odometer.present?
      "In progress"
    else
      "Not yet started"
    end
  end
end