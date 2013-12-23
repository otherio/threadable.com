require_dependency 'covered/conversation'

class Covered::Conversation::Recipients

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def all
    scope.map{ |recipient| recipient_for recipient }
  end

  def build
    recipient_for scope.build
  end

  def inspect
    %(#<#{self.class} conversation_id: #{conversation.id.inspect}>)
  end

  private

  def scope
    conversation.conversation_record.recipients.unload
  end

  def recipient_for user_record
    Covered::User.new(covered, user_record) if user_record
  end

end
