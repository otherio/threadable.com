class ConversationMessageCreator < MethodObject.new(:user, :conversation, :message_attributes)

  def call
    message = @conversation.messages.new(@message_attributes)
    message.user = @user
    message.from = @user.email
    message.subject ||= @conversation.subject
    message.class.transaction do
      message.save
      MessageDispatch.new(message, email_sender: true).enqueue
    end
    message
  end

end
