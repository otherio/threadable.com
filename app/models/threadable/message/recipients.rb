require_dependency 'threadable/message'

class Threadable::Message::Recipients < Threadable::Conversation::Recipients

  def initialize message
    @message = message
    @conversation = message.conversation
  end
  attr_reader :message, :conversation
  delegate :threadable, to: :message

  private

  def scope
    if message.parent_message.nil?
      groups = conversation.groups.all
      scope_without_groups.in_groups_with_each_message_including_followers(conversation.id, groups.map(&:id), true)
    else
      super
    end
  end

end
