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

  private

  def scope
    conversation.conversation_record.events
  end

end
