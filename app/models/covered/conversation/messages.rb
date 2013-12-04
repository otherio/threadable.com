class Covered::Conversation::Messages < Covered::Messages

  def initialize conversation
    @conversation = conversation
    @covered = conversation.covered
  end
  attr_reader :conversation

  def create attributes
    super attributes.merge(conversation: conversation)
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    conversation.conversation_record.messages
  end

end
