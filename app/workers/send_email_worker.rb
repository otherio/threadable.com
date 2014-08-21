#
# Example usage:
#   threadable.emails.send_email_async(:conversation_message, organization_id, message_id, recipient_id)
#
class SendEmailWorker < Threadable::Worker

  def perform! type, *args
    send type, *args
  end

  def conversation_message organization_id, message_id, recipient_id
    organization   = threadable.organizations.find_by_id! organization_id
    message   = organization.messages.find_by_id! message_id
    recipient = organization.members.find_by_user_id! recipient_id

    return unless recipient.subscribed?
    threadable.emails.send_email(:conversation_message, organization, message, recipient)

    # this marks the sent email record, if there is one, as delivered to mailgun
    message.sent_email(recipient).try(:relayed!)
  end

  def message_summary organization_id, recipient_id, time, zone = 'US/Pacific'
    time = Time.parse(time).in_time_zone(zone)

    organization   = threadable.organizations.find_by_id! organization_id
    recipient      = organization.members.find_by_user_id! recipient_id
    conversations  = recipient.summarized_conversations time

    return unless recipient.subscribed?
    threadable.emails.send_email(:message_summary, organization, recipient, conversations, time) if conversations.length > 0
  end

  def join_notice organization_id, recipient_id, personal_message=nil
    organization = threadable.organizations.find_by_id! organization_id
    recipient    = organization.members.find_by_user_id! recipient_id

    return unless recipient.subscribed?
    threadable.emails.send_email(:join_notice, organization, recipient, personal_message)
  end

  def self_join_notice organization_id, recipient_id
    organization = threadable.organizations.find_by_id! organization_id
    recipient    = organization.members.find_by_user_id! recipient_id

    return unless recipient.subscribed?
    threadable.emails.send_email(:self_join_notice, organization, recipient)
  end

  def self_join_notice_confirm organization_id, recipient_id
    organization = threadable.organizations.find_by_id! organization_id
    recipient    = organization.members.find_by_user_id! recipient_id

    return unless recipient.subscribed?
    threadable.emails.send_email(:self_join_notice_confirm, organization, recipient)
  end

  def invitation organization_id, recipient_id
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:invitation, organization, recipient)
  end

  def unsubscribe_notice organization_id, recipient_id
    organization   = threadable.organizations.find_by_id! organization_id
    recipient = organization.members.find_by_user_id! recipient_id
    threadable.emails.send_email(:unsubscribe_notice, organization, recipient)
  end

  def added_to_group_notice organization_id, group_id, sender_id, recipient_id
    begin
      organization = threadable.organizations.find_by_id! organization_id
      group        = organization.groups.find_by_id! group_id
      sender       = organization.members.find_by_user_id! sender_id
      recipient    = organization.members.find_by_user_id! recipient_id
    rescue Threadable::RecordNotFound
      return
    end

    return unless recipient.subscribed?
    threadable.emails.send_email(:added_to_group_notice, organization, group, sender, recipient)
  end

  def removed_from_group_notice organization_id, group_id, sender_id, recipient_id
    organization = threadable.organizations.find_by_id! organization_id
    group        = organization.groups.find_by_id! group_id
    sender       = organization.members.find_by_user_id! sender_id
    recipient    = organization.members.find_by_user_id! recipient_id

    return unless recipient.subscribed?
    threadable.emails.send_email(:removed_from_group_notice, organization, group, sender, recipient)
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
