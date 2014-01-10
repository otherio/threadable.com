class Api::MessagesSerializer < Serializer

  def serialize_record message
    {
      id:                message.id,
      unique_id:         message.unique_id,
      from:              message.from,
      subject:           message.subject,

      body:              message.body,
      body_stripped:     message.body_stripped,

      message_id_header: message.message_id_header,
      references_header: message.references_header,
      date_header:       message.date_header,

      html:              message.html?,
      root:              message.root?,
      shareworthy:       message.shareworthy?,
      knowledge:         message.knowledge?,
      created_at:        message.created_at,

      parent_message_id: message.parent_message_id,

      links: {
        conversation:    api_organization_conversation_path(message.conversation.organization, message.conversation),
      },
    }
  end

end
