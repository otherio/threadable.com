class MailPreview < MailView

  def conversation_message
    message = Message.joins(:conversation).where(:conversations => {type:nil}).last!
    generate_conversation_message message
  end

  def task_message
    message = Message.joins(:conversation).where(:conversations => {type: 'Task'}).last!
    generate_conversation_message message
  end

  def join_notice
    project, recipient = find_project_and_recipient
    covered.emails.generate(:join_notice, project, recipient, "Yo Dawg!")
  end

  def unsubscribe_notice
    project, recipient = find_project_and_recipient
    covered.emails.generate(:unsubscribe_notice, project, recipient)
  end


  def sign_up_confirmation
    covered.emails.generate(:sign_up_confirmation, find_recipient)
  end

  def reset_password
    covered.emails.generate(:reset_password, find_recipient)
  end

  def message_held_notice
    covered.emails.generate(:message_held_notice, covered.incoming_emails.latest)
  end

  def message_accepted_notice
    covered.emails.generate(:message_accepted_notice, covered.incoming_emails.latest)
  end

  def message_rejected_notice
    covered.emails.generate(:message_rejected_notice, covered.incoming_emails.latest)
  end

  def email_address_confirmation
    covered.emails.generate(:email_address_confirmation, covered.users.all.last.email_addresses.all.last)
  end

  private

  def covered
    @covered ||= Covered.new(host: 'example.com', port: 3000, protocol: 'http')
  end

  def generate_conversation_message message
    covered.current_user_id = message.creator_id
    project      = covered.current_user.projects.find_by_id!(message.conversation.project_id)
    conversation = project.conversations.find_by_id!(message.conversation.id)
    message      = conversation.messages.latest
    recipient    = project.members.all.last
    covered.emails.generate(:conversation_message, project, message, recipient)
  end

  def find_project_and_recipient
    project_record   = Organization.last!
    recipient_record = project_record.members.last!

    covered.current_user_id = project_record.members.first!
    project   = covered.current_user.projects.find_by_id!(project_record.id)
    recipient = project.members.find_by_user_id!(recipient_record.id)
    [project, recipient]
  end

  def find_recipient
    covered.users.find_by_id!(User.last!.id)
  end

end
