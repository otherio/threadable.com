class Threadable::Events::Create < MethodObject

  def call events, event_type, attributes
    threadable = events.threadable

    event_type.present? or raise ArgumentError, 'event type required'
    event_type = event_type.to_sym
    ::Event::TYPES.include?(event_type) or raise ArgumentError, "invalid event type: #{event_type.to_s.inspect}"

    content = attributes.slice!(
      :organization,
      :organization_id,
      :conversation,
      :conversation_id,
      :user,
      :user_id,
      :created_at,
    )
    attributes[:user_id]    ||= threadable.current_user_id
    attributes[:event_type] = event_type
    attributes[:content]    = content

    event_record = Event.create(attributes)
    event = "Threadable::Events::#{event_type.to_s.camelize}".constantize.new(threadable, event_record)
    return event unless event.persisted?

    threadable.track(event.tracking_name, attributes.except(:event_type))
    return event
  end

end
