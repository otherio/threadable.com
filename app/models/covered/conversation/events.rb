require_dependency 'covered/conversation'

class Covered::Conversation::Events < Covered::Events

  def initialize conversation
    super(conversation.covered)
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

    messages = conversation.messages.all

    message_events = messages.map do |message|
      MessageEvent.new(message)
    end

    return (events + message_events).sort_by(&:created_at)
  end

  private

  def event_for event_record
    return nil if event_record.nil?
    event_type = event_record.event_type.to_s.camelize
    "Covered::Events::#{event_type}".constantize.new(covered, event_record)
  end

  def message_for message_record
    return nil if message_record.nil?
    Covered::Message.new(covered, message_record) if message_record
  end

  def scope
    conversation.conversation_record.events
  end

end
