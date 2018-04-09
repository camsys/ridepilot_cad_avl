class GpsLocationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :gps_location  # optional

  attribute :latitude, :longitude, :bearing, :speed, :run_id
end