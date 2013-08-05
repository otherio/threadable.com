class SendConversationMessageWorker < ResqueWorker.new(:params)

  queue :conversation_mail

  # {message_id: Integer, email_sender: Boolean}
  def call
    @message = Message.find(@params['message_id'])
    @project = @message.conversation.project

    memberships = @project.memberships.that_get_email.includes(:user)

    if !@params['email_sender']
      memberships.reject! do |membership|
        membership.user == @message.user
      end
    end

    memberships.each do |membership|
      ConversationMailer.conversation_message(@message, membership).deliver
    end
  end

end
