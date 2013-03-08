class MessageDispatch
  def initialize(message)
    @message = message
  end

  def enqueue
    project = @message.conversation.project
    reply_to = "#{project.name} <#{project.slug}@multifyapp.com>"
    project.members.each do |user|
      next if user.id == @message.user.id

      SendConversationMessageWorker.enqueue(
        recipient: user,
        sender: @message.user,
        message: @message,
        parent_message: @message.parent_message,
        reply_to: reply_to
      )
    end
  end

end
