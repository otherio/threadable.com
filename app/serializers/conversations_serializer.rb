class ConversationsSerializer < Serializer
  def serialize_record conversation
    doers = conversation.task? ? conversation.doers.all : nil
    {
      id:                 conversation.id,
      slug:               conversation.slug,
      organization_slug:  conversation.organization.slug,
      subject:            conversation.subject,
      task:               conversation.task?,
      created_at:         conversation.created_at,
      updated_at:         conversation.updated_at,
      last_message_at:    conversation.last_message_at,
      participant_names:  conversation.participant_names,
      number_of_messages: conversation.messages.count,
      message_summary:    conversation.message_summary,
      group_ids:          conversation.group_ids,
      doers:              conversation.task? ? serialize(:doers, doers) : [],
      doing:              conversation.task? ? doers.map(&:user_id).include?(current_user.id) : nil,
      done_at:            conversation.task? ? conversation.done_at : nil,
      done:               conversation.task? ? conversation.done? : nil,
      position:           conversation.task? ? conversation.position : -1,
      muted:              conversation.muted?,
    }
  end
end
