class ConversationMessageCreator < MethodObject.new(:user, :conversation, :message_attributes)

  def call
    body = @message_attributes.delete(:body)
    stripped_body = strip_html(body)
    @message_attributes[:body_html]      = body
    @message_attributes[:stripped_html]  = body
    @message_attributes[:body_plain]     = stripped_body
    @message_attributes[:stripped_plain] = stripped_body

    @message_attributes[:parent_message] = @conversation.messages.last

    attachments = Array(@message_attributes.try(:delete, :attachments))
    message = @conversation.messages.new(@message_attributes)
    message.user = @user
    message.from = @user.email
    message.subject ||= @conversation.subject
    message.class.transaction do
      message.save
      message.attachments = attachments.map{|attachment| Attachment.create!(attachment) }
      SendConversationMessageWorker.enqueue(message_id: message.id, email_sender: true)
    end
    message
  end

  def strip_html(html)
    HTMLEntities.new.decode Sanitize.clean(html.gsub(%r{<br/?>}, "\n"))
  end

end
