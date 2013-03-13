class MessageDispatch

  def initialize(message)
    @message = message
  end

  def enqueue
    project = @message.conversation.project
    project.project_memberships.all

    project.members_who_get_email.each do |user|
      next if user.id == @message.user.id

      SendConversationMessageWorker.enqueue(
        :project_id                => project.id,
        :project_slug              => project.slug,
        :conversation_slug         => @message.conversation.slug,
        :message_subject           => @message.subject,
        :sender_name               => @message.user.name,
        :sender_email              => @message.user.email,
        :recipient_name            => user.name,
        :recipient_email           => user.email,
        :message_body              => @message.body,
        :message_message_id_header => @message.message_id_header,
        :message_references_header => @message.references_header,
        :parent_message_id_header  => @message.parent_message.try(:message_id_header),
        :reply_to                  => project.formatted_email_address,
      )
    end
  end

end
