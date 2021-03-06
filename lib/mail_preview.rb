class MailPreview < MailView

  def conversation_message
    message = Message.joins(:conversation).where(:conversations => {type:nil}).last!
    generate_conversation_message message
  end

  def conversation_in_group_message
    message = Message.joins(conversation: :groups).where(:conversations => {type:nil}).last!
    generate_conversation_message message
  end

  def task_message
    message = Message.joins(:conversation).where(:conversations => {type: 'Task'}).last!
    generate_conversation_message message
  end

  def task_in_group_message
    message = Message.joins(conversation: :groups).where(:conversations => {type: 'Task'}).last!
    generate_conversation_message message
  end

  def join_notice
    organization, recipient = find_organization_and_recipient
    threadable.emails.generate(:join_notice, organization, recipient, "Yo Dawg!")
  end

  def confirmation_notice
    organization, recipient = find_organization_and_recipient
    threadable.emails.generate(:confirmation_notice, organization, recipient)
  end

  def self_join_notice
    organization, recipient = find_organization_and_recipient
    threadable.emails.generate(:self_join_notice, organization, recipient)
  end

  def self_join_notice_confirm
    organization, recipient = find_organization_and_recipient
    threadable.emails.generate(:self_join_notice_confirm, organization, recipient)
  end

  def unsubscribe_notice
    organization, recipient = find_organization_and_recipient
    threadable.emails.generate(:unsubscribe_notice, organization, recipient)
  end


  def sign_up_confirmation
    threadable.emails.generate(:sign_up_confirmation, 'Zero point energy machine', 'john@the-hutchison-effect.org')
  end

  def reset_password
    threadable.emails.generate(:reset_password, find_recipient)
  end

  def message_held_notice
    threadable.emails.generate(:message_held_notice, threadable.incoming_emails.latest)
  end

  def message_held_owner_notice
    threadable.emails.generate(:message_held_owner_notice, threadable.incoming_emails.latest, threadable.incoming_emails.latest.organization.members.all.first)
  end

  def message_accepted_notice
    threadable.emails.generate(:message_accepted_notice, threadable.incoming_emails.latest)
  end

  def message_rejected_notice
    threadable.emails.generate(:message_rejected_notice, threadable.incoming_emails.latest)
  end

  def email_address_confirmation
    threadable.emails.generate(:email_address_confirmation, threadable.users.all.last.email_addresses.all.last)
  end

  def added_to_group_notice
    organization, recipient = find_organization_and_recipient
    group = organization.groups.all.first
    sender = organization.members.all.sample
    threadable.emails.generate(:added_to_group_notice, organization, group, sender, recipient)
  end

  def message_summary
    time = Time.now.in_time_zone('US/Pacific') - 1.day
    random_message = Message.last!
    threadable.current_user_id = random_message.creator_id

    organization  = threadable.current_user.organizations.find_by_id!(random_message.conversation.organization_id)
    conversations = organization.conversations.for_message_summary(random_message.creator, time)
    recipient     = organization.members.all.last

    threadable.emails.generate(:message_summary, organization, recipient, conversations, time)
  end

  private

  def threadable
    @threadable ||= Threadable.new(host: 'localhost', port: 3000, protocol: 'http')
  end

  def generate_conversation_message message
    threadable.current_user_id = message.creator_id
    organization = threadable.current_user.organizations.find_by_id!(message.conversation.organization_id)
    conversation = organization.conversations.find_by_id!(message.conversation.id)
    message      = conversation.messages.latest
    recipient    = organization.members.all.last
    threadable.emails.generate(:conversation_message, organization, message, recipient)
  end

  def find_organization_and_recipient
    organization_record   = Organization.last!
    recipient_record = organization_record.members.active.last!

    threadable.current_user_id = organization_record.members.first!.id
    organization   = threadable.current_user.organizations.find_by_id!(organization_record.id)
    recipient = organization.members.find_by_user_id!(recipient_record.id)
    [organization, recipient]
  end

  def find_recipient
    threadable.users.find_by_id!(User.last!.id)
  end

end
