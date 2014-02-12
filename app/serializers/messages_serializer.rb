class MessagesSerializer < Serializer

  def serialize_record message
    json = {
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
      sent_at:           message.sent_at,

      parent_message_id: message.parent_message_id,

      avatar_url:        message.avatar_url,
      sender_name:       message.sender_name,

      attachments:       message.attachments.all.map do |attachment|
        {
          url:        attachment.url,
          filename:   attachment.filename,
          mimetype:   attachment.mimetype,
          size:       attachment.size,
          content_id: attachment.content_id,
        }
      end,
    }

    if Array(options[:include]).include? :conversation
      json[:conversation] = serialize(:conversations, message.conversation)
    end

    json
  end

end
