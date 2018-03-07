class VehicleSerializer
  include FastJsonapi::ObjectSerializer
  set_type :vehicle  # optional
  attributes :name
end