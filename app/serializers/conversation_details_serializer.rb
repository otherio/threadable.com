class ConversationDetailsSerializer < Serializer
  def serialize_record conversation
    {
      id:                 conversation.id,
      slug:               conversation.slug,
      recipient_ids:      conversation.recipients.all.map(&:id),
      muter_count:        conversation.muter_count,
      follower_ids:       conversation.recipient_follower_ids,
    }
  end
end
