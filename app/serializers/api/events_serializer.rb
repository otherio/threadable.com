class Api::EventsSerializer < Serializer

  def serialize_record event
    {
      id:         event.id,
      event_type: event.event_type,
      user_id:    event.actor_id,
      content:    event.content,
      created_at: event.created_at,
      message:    event.respond_to?(:message) ? serialize(:messages, event.message) : nil,
    }
  end

end
