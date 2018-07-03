class RoutineMessageSerializer
  include FastJsonapi::ObjectSerializer
  set_type :routine_message  # optional

  attribute :id, :body, :driver_id, :provider_id, :sender_id, :created_at

  attribute :sender_name do |object|
    object.sender.display_name if object.sender
  end

end