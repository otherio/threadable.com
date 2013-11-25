class Covered::CurrentUser::Project::Conversation::Recipients

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
    %(#<#{self.class}>)
  end

  private

  def scope
    conversation.conversation_record.recipients
  end

  def recipient_for user_record
    Covered::CurrentUser::Project::Conversation::Recipient.new(conversation, user_record)
  end

end

require 'covered/current_user/project/conversation/recipient'
