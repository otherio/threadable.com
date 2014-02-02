require_dependency 'threadable/conversation'

class Threadable::Conversation::Messages < Threadable::Messages

  def initialize conversation
    @conversation = conversation
    @threadable = conversation.threadable
  end
  attr_reader :conversation

  def count
    conversation.conversation_record.messages_count
  end

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
