class Covered::Events::Create < MethodObject

  def call events, event_type, attributes
    covered = events.covered

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
    attributes[:user_id]    ||= covered.current_user_id
    attributes[:event_type] = event_type
    attributes[:content]    = content

    event_record = Event.create(attributes)
    event = "Covered::Events::#{event_type.to_s.camelize}".constantize.new(covered, event_record)
    return event unless event.persisted?

    covered.track(event.tracking_name, attributes.except(:event_type))
    return event
  end

end
