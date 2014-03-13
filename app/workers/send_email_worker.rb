#
# Example usage:
#   threadable.emails.send_async(:conversation_message, recipient_id, organization_id, message_id)
#
class SendEmailWorker < Threadable::Worker

  def perform! type, *args
    send type, *args
  end

  def conversation_message recipient_id, organization_id, message_id
    organization   = threadable.organizations.find_by_id! organization_id
    message   = organization.messages.find_by_id! message_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:conversation_message, recipient, organization, message)

    # this marks the sent email record, if there is one, as delivered to mailgun
    message.sent_email(recipient).try(:relayed!)
  end

  def message_summary recipient_id, organization_id, time, zone = 'US/Pacific'
    time = Time.parse(time).in_time_zone(zone)

    organization   = threadable.organizations.find_by_id! organization_id
    recipient      = organization.members.find_by_user_id! recipient_id
    conversations  = recipient.summarized_conversations time

    threadable.emails.send_email(:message_summary, recipient, organization, conversations, time) if conversations.length > 0
  end

  def join_notice recipient_id, organization_id, personal_message=nil
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:join_notice, recipient, organization, personal_message)
  end

  def invitation recipient_id, organization_id
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:invitation, recipient, organization)
  end

  def unsubscribe_notice recipient_id, organization_id
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:unsubscribe_notice, recipient, organization)
  end

  def added_to_group_notice recipient_id, organization_id, group_id, sender_id
    organization = threadable.organizations.find_by_id! organization_id
    group        = organization.groups.find_by_id! group_id
    sender       = organization.members.find_by_user_id! sender_id
    recipient    = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:added_to_group_notice, recipient, organization, group, sender)
  end

  def removed_from_group_notice recipient_id, organization_id, group_id, sender_id
    organization = threadable.organizations.find_by_id! organization_id
    group        = organization.groups.find_by_id! group_id
    sender       = organization.members.find_by_user_id! sender_id
    recipient    = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:removed_from_group_notice, recipient, organization, group, sender)
  end

  def sign_up_confirmation organization_name, email_address
    threadable.emails.send_email(:sign_up_confirmation, organization_name, email_address)
  end

  def reset_password recipient_id
    recipient = threadable.users.find_by_id! recipient_id
    threadable.emails.send_email(:reset_password, recipient)
  end

  def email_address_confirmation email_address_id
    email_address = threadable.email_addresses.find_by_id!(email_address_id)
    threadable.emails.send_email(:email_address_confirmation, email_address)
  end

  def spam_complaint params
    threadable.emails.send_email(:spam_complaint, params)
  end

end
