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
    if conversation.trashed?
      raise Threadable::AuthorizationError, 'This conversation has been deleted. Remove it from the trash before replying.'
    end

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
