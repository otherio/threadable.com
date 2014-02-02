require_dependency 'threadable/conversation'

class Threadable::Conversation::Events < Threadable::Events

  def initialize conversation
    super(conversation.threadable)
    @conversation = conversation
  end
  attr_reader :conversation

  def create event_type, attributes={}
    attributes = attributes.dup.symbolize_keys!
    attributes[:organization_id] = conversation.organization.id
    attributes[:conversation_id] = conversation.id
    attributes.delete(:organization)
    attributes.delete(:conversation)
    super event_type, attributes
  end

  def with_messages
    events = all
    messages = conversation.messages.all_with_creator_and_attachments

    message_events = messages.map do |message|
      MessageEvent.new(message)
    end

    return (events + message_events).sort_by(&:created_at)
  end

  private

  def event_for event_record
    return nil if event_record.nil?
    event_type = event_record.event_type.to_s.camelize
    "Threadable::Events::#{event_type}".constantize.new(threadable, event_record)
  end

  def message_for message_record
    return nil if message_record.nil?
    Threadable::Message.new(threadable, message_record) if message_record
  end

  def scope
    conversation.conversation_record.events
  end

end
