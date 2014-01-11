class Api::ConversationsSerializer < Serializer

  def serialize_record conversation
    {
      id:                 conversation.id,
      param:              conversation.to_param,
      slug:               conversation.slug,
      subject:            conversation.subject,
      task:               conversation.task?,
      created_at:         conversation.created_at,
      updated_at:         conversation.updated_at,
      participant_names:  conversation.participant_names,
      number_of_messages: conversation.messages.count,
      message_summary:    conversation.messages.latest.try(:body_plain),
      group_ids:          conversation.groups.all.map(&:id),
    }
  end

end
