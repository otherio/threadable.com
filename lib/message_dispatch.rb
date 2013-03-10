class MessageDispatch
  def initialize(message)
    @message = message
  end

  def enqueue
    project = @message.conversation.project

    # note: reply_to could be moved into ConversationMailer if we want. not sure if we do, but it has
    # access to the project object now.
    reply_to = "#{project.name} <#{project.slug}@multifyapp.com>"

    project.members.each do |user|
      next if user.id == @message.user.id

      SendConversationMessageWorker.enqueue(
        sender: @message.user,
        recipient: user,
        message: @message,
        parent_message: @message.parent_message,
        project: project,
        reply_to: reply_to
      )
    end
  end

end
