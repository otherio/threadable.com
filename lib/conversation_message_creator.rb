class ConversationMessageCreator < MethodObject.new(:user, :conversation, :message_attributes)

  def call
    message = @conversation.messages.new(@message_attributes)
    message.user = @user
    message.subject ||= @conversation.subject
    MessageDispatch.new(message).enqueue if message.save
    message
  end

end
