class AddressSerializer
  include FastJsonapi::ObjectSerializer
  set_type :address  # optional

  attribute :name, :address, :city, :latitude, :longitude, :notes, :one_line_text

  attribute :latlng_only do |object|
    object.coded_by_lat_lng?
  end
end