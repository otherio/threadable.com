#
# Example usage:
#   covered.emails.schedule_send(:conversation_message, organization_id, message_id, recipient_id)
#
class SendEmailWorker < Covered::Worker

  def perform! type, *args
    send type, *args
  end

  def conversation_message organization_id, message_id, recipient_id
    organization   = covered.organizations.find_by_id! organization_id
    message   = organization.messages.find_by_id! message_id
    recipient = organization.members.find_by_user_id! recipient_id
    covered.emails.send_email(:conversation_message, organization, message, recipient)
  end

  def join_notice organization_id, recipient_id, personal_message=nil
    organization   = covered.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    covered.emails.send_email(:join_notice, organization, recipient, personal_message)
  end

  def unsubscribe_notice organization_id, recipient_id
    organization   = covered.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    covered.emails.send_email(:unsubscribe_notice, organization, recipient)
  end

  def sign_up_confirmation recipient_id
    recipient = covered.users.find_by_id! recipient_id
    covered.emails.send_email(:sign_up_confirmation, recipient)
  end

  def reset_password recipient_id
    recipient = covered.users.find_by_id! recipient_id
    covered.emails.send_email(:reset_password, recipient)
  end

  def email_address_confirmation email_address_id
    email_address = covered.email_addresses.find_by_id!(email_address_id)
    covered.emails.send_email(:email_address_confirmation, email_address)
  end

end
