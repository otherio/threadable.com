#
# Example usage:
#   threadable.emails.schedule_send(:conversation_message, organization_id, message_id, recipient_id)
#
class SendEmailWorker < Threadable::Worker

  def perform! type, *args
    send type, *args
  end

  def conversation_message organization_id, message_id, recipient_id
    organization   = threadable.organizations.find_by_id! organization_id
    message   = organization.messages.find_by_id! message_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:conversation_message, organization, message, recipient)

    # there is a tiny chance an email could get sent a second time here. email is nonatomic. deal with it.
    message.sent_email(recipient).relayed!
  end

  def message_summary organization_id, recipient_id, time
    # this should send a summary of all mail from the org on the given date, for now.
    organization   = threadable.organizations.find_by_id! organization_id
    conversations  = organization.conversations.all_with_updated_date time
    recipient      = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:message_summary, organization, recipient, conversations, time)
  end

  def join_notice organization_id, recipient_id, personal_message=nil
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:join_notice, organization, recipient, personal_message)
  end

  def unsubscribe_notice organization_id, recipient_id
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:unsubscribe_notice, organization, recipient)
  end

  def added_to_group_notice organization_id, group_id, sender_id, recipient_id
    organization = threadable.organizations.find_by_id! organization_id
    group        = organization.groups.find_by_id! group_id
    sender       = organization.members.find_by_user_id! sender_id
    recipient    = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:added_to_group_notice, organization, group, sender, recipient)
  end

  def removed_from_group_notice organization_id, group_id, sender_id, recipient_id
    organization = threadable.organizations.find_by_id! organization_id
    group        = organization.groups.find_by_id! group_id
    sender       = organization.members.find_by_user_id! sender_id
    recipient    = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:removed_from_group_notice, organization, group, sender, recipient)
  end

  def sign_up_confirmation recipient_id
    recipient = threadable.users.find_by_id! recipient_id
    threadable.emails.send_email(:sign_up_confirmation, recipient)
  end

  def reset_password recipient_id
    recipient = threadable.users.find_by_id! recipient_id
    threadable.emails.send_email(:reset_password, recipient)
  end

  def email_address_confirmation email_address_id
    email_address = threadable.email_addresses.find_by_id!(email_address_id)
    threadable.emails.send_email(:email_address_confirmation, email_address)
  end

end
