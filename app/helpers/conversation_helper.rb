module ConversationHelper
  def participants_or_creator(conversation)
    conversation.participants.all.presence || [conversation.creator]
  end
end
