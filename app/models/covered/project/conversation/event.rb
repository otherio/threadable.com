class Covered::Project::Conversation::Event

  def initialize conversation, event_record
    @conversation, @event_record = conversation, event_record
  end
  attr_reader :conversation, :event_record
  delegate :covered, to: :conversation

  delegate *%w{
    id
    type
    created_at
  }, to: :event_record


  def human_readable_type
    type.split('::').last.underscore[/^(.*)_event$/,1].sub('_', ' ')
  end

  def actor_id
    event_record.user_id
  end

  def actor
    @actor ||= Covered::User.new(covered, event_record.user)
  end

  def as_json options=nil
    {
      type:            human_readable_type,
      actor_id:        actor_id,
      conversation_id: conversation.id,
    }
  end


  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class}>)
  end

end
