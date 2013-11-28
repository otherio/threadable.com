#
# Example usage:
#   covered.emails.schedule_send(:conversation_message, project_id, message_id, recipient_id)
#
class SendEmailWorker < Covered::Worker

  def perform! type, *args
    send type, *args
  end

  def conversation_message project_id, message_id, recipient_id
    project   = covered.projects.find_by_id! project_id
    message   = project.messages.find_by_id! message_id
    recipient = project.members.find_by_user_id! recipient_id
    covered.emails.send_email(:conversation_message, project, message, recipient)
  end

  def join_notice project_id, recipient_id, personal_message=nil
    project   = current_user.projects.find_by_id! project_id
    recipient = project.members.find_by_user_id! recipient_id
    covered.emails.send_email(:join_notice, project, recipient, personal_message)
  end

  def unsubscribe_notice project_id, recipient_id
    project = current_user.projects.find_by_id! project_id
    recipient = project.members.find_by_user_id! recipient_id
    covered.emails.send_email(:unsubscribe_notice, project, recipient)
  end

  def sign_up_confirmation recipient_id
    recipient = covered.users.find_by_id! recipient_id
    covered.emails.send_email(:sign_up_confirmation, recipient)
  end

  def reset_password recipient_id
    recipient = covered.users.find_by_id! recipient_id
    covered.emails.send_email(:reset_password, recipient)
  end

end
