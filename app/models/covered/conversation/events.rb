require_dependency 'covered/conversation'

class Covered::Conversation::Events < Covered::Events

  def initialize conversation
    super(conversation.covered)
    @conversation = conversation
  end
  attr_reader :conversation


  private

  def scope
    conversation.conversation_record.events
  end

end
