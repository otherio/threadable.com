class MailPreview < MailView

  def conversation_message
    message = Message.joins(:conversation).where(:conversations => {type:nil}).last!
    covered.generate_email(:conversation_message, message_id: message.id, recipient_id: message.project.members.last!.id)
  end

  def task_message
    message = Message.joins(:conversation).where(:conversations => {type:"Task"}).last!
    covered.generate_email(:conversation_message, message_id: message.id, recipient_id: message.project.members.last!.id)
  end

  def sign_up_confirmation
    covered.generate_email(:sign_up_confirmation, recipient_id: Covered::User.last!.id)
  end

end
