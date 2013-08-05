class ConversationCreator < MethodObject.new(:project, :creator, :subject, :message)

  def call
    Conversation.transaction do
      create_conversation!
      create_first_message!
      @conversation
    end
  end

  def create_conversation!
    @conversation = @project.conversations.create!(
      creator: @creator,
      subject: @subject,
    )
  end

  def create_first_message!
    @conversation_message = ConversationMessageCreator.call(@creator, @conversation, @message)
    raise ActiveRecord::Rollback unless @conversation_message.persisted?
  end

end
