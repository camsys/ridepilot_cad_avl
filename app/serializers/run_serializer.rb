class RunSerializer
  include FastJsonapi::ObjectSerializer
  set_type :run  # optional
  attributes :name, :date, :scheduled_start_time_string, :scheduled_end_time_string
end