module ConversationHelper
  def participants_or_creator(conversation)
    conversation.participants.presence || [conversation.creator]
  end
end
