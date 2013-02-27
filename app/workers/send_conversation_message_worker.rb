class SendConversationMessageWorker < ResqueWorker.new(:params)

  queue :conversation_mail

  def call
    @params.symbolize_keys!
    ConversationMailer.conversation_message(@params).deliver
  end
end
