class DriverMessageTemplateSerializer
  include FastJsonapi::ObjectSerializer
  set_type :driver_message_template  # optional

  attribute :id, :message
end