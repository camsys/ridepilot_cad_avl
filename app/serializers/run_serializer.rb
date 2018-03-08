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
end