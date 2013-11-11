class MailPreview < MailView

  def conversation_message
    message = Covered::Message.joins(:conversation).where(:conversations => {type:nil}).last!
    covered = Covered.new(host: 'example.com', port: 3000, current_user: message.user)

    covered.generate_email(type: :conversation_message, options: {message_id: message.id, recipient_id: message.project.members.last!.id})
  end

  def task_message
    message = Covered::Message.joins(:conversation).where(:conversations => {type: 'Covered::Task'}).last!
    covered = Covered.new(host: 'example.com', port: 3000, current_user: message.user)

    covered.generate_email(type: :conversation_message, options: {message_id: message.id, recipient_id: message.project.members.last!.id})
  end

  def sign_up_confirmation
    covered = Covered.new(host: 'example.com', port: 3000, current_user: nil)
    covered.generate_email(type: :sign_up_confirmation, options: {recipient_id: Covered::User.last!.id})
  end

end
