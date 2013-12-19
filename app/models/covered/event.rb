class Covered::Event < Covered::Model

  def initialize covered, event_record
    @covered, @event_record = covered, event_record
  end
  attr_reader :event_record

  delegate(*%w{
    id
    type
    project_id
    conversation_id
    content
    created_at
    persisted?
  }, to: :event_record)

  def human_readable_type
    type.split('::').last.underscore[/^(.*)_event$/,1].sub('_', ' ')
  end

  def tracking_name
    event_name = type.split('::').join('_').underscore[/^(.*)_event$/,1]
    event_name.present? ? event_name.split('_').map(&:capitalize).join(' ') : 'Event'
  end

  def actor_id
    event_record.user_id
  end

  def actor
    @actor ||= Covered::User.new(covered, event_record.user) if actor_id
  end

  def conversation
    @conversation ||= Covered::Conversation.new(covered, event_record.conversation)
  end

  def task
    conversation if conversation.task?
  end

  def inspect
    %(#<#{self.class} id: #{id.inspect}>)
  end

  def as_json options=nil
    {
      type:            human_readable_type,
      actor_id:        actor_id,
      conversation_id: conversation_id,
    }
  end

end
