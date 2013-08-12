class MailPreview < MailView

  def conversation_message
    message = Message.joins(:conversation).where(:conversations => {type:nil}).last!
    project_membership = message.project.project_memberships.readonly.last
    ConversationMailer.conversation_message(message, project_membership)
  end

  def task_message
    message = Message.joins(:conversation).where(:conversations => {type:"Task"}).last!
    project_membership = message.project.project_memberships.readonly.last
    ConversationMailer.conversation_message(message, project_membership)
  end

end
