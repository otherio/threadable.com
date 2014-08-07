class ConversationDetailsSerializer < Serializer
  def serialize_record conversation
    {
      id:                 conversation.id,
      slug:               conversation.slug,
      recipient_ids:      conversation.recipients.all.map(&:id),
      muter_count:        conversation.muter_ids.length,
      follower_ids:       conversation.follower_ids,
    }
  end
end
