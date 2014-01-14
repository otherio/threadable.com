class Api::ConversationsSerializer < Serializer

  def serialize_record conversation
    {
      id:                 conversation.id,
      slug:               conversation.slug,
      organization_slug:  conversation.organization.slug,
      subject:            conversation.subject,
      task:               conversation.task?,
      created_at:         conversation.created_at,
      updated_at:         conversation.updated_at,
      participant_names:  conversation.participant_names,
      number_of_messages: conversation.messages.count,
      message_summary:    conversation.messages.latest.try(:body_plain).try(:[], 0..50),
      group_ids:          conversation.groups.all.map(&:id),
      doers:              conversation.task? ? serialize(:doers, conversation.doers.all) : [],
      done:               conversation.task? ? conversation.done? : nil,
    }
  end

end
