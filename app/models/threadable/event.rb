class Threadable::Event < Threadable::Model

  def initialize threadable, event_record
    @threadable, @event_record = threadable, event_record
  end
  attr_reader :event_record

  delegate(*%w{
    id
    event_type
    organization_id
    conversation_id
    content
    created_at
    persisted?
    errors
  }, to: :event_record)

  def tracking_name
    event_type.to_s.split('_').map(&:capitalize).join(' ')
  end

  def actor_id
    event_record.user_id
  end

  def actor
    @actor ||= Threadable::User.new(threadable, event_record.user) if event_record.user
  end

  def organization
    @organization ||= Threadable::Organization.new(threadable, event_record.organization) if event_record.organization
  end

  def conversation
    @conversation ||= Threadable::Conversation.new(threadable, event_record.conversation) if event_record.conversation
  end

  def task
    conversation if conversation.task?
  end

  def inspect
    %(#<#{self.class} id: #{id.inspect}>)
  end

  def as_json options=nil
    {
      event_type:      event_type,
      actor_id:        actor_id,
      conversation_id: conversation_id,
    }
  end

end
