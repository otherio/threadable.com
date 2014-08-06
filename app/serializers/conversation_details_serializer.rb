class ConversationDetailsSerializer < Serializer
  def serialize_record conversation
    {
      id:                 conversation.id,
      slug:               conversation.slug,
      organization_slug:  conversation.organization.slug,
      recipient_ids:      conversation.recipients.all.map(&:id),
      muter_ids:          conversation.muter_ids,
      follower_ids:       conversation.follower_ids,
    }
  end
end
