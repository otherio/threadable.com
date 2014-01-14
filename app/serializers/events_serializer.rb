class EventsSerializer < Serializer

  def serialize_record event
    {
      id:         event.id,
      event_type: event.event_type,
      actor:      event.actor.present? ? event.actor.name : nil,
      doer:       event.respond_to?(:doer) ? event.doer.name : nil,
      created_at: event.created_at,
      message:    event.respond_to?(:message) ? serialize(:messages, event.message) : nil,
    }
  end

end
