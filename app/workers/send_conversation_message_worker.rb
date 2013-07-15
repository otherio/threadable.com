class SendConversationMessageWorker < ResqueWorker.new(:params)

  queue :conversation_mail

  # {message_id: Integer, email_sender: Boolean}
  def call
    @message = Message.find(@params['message_id'])
    @project = @message.conversation.project

    @project.members_who_get_email.each do |user|
      next if !@params['email_sender'] && user.id == @message.user.id

      ConversationMailer.conversation_message(@message, user).deliver
    end
  end

end
