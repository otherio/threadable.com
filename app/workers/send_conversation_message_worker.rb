class SendConversationMessageWorker < ResqueWorker.new(:recipient, :message)

  queue :conversation_mail

  def call
    ConversationMailer.conversation_message(recipient, message).deliver
  end
end
