class Covered::Operations::CreateMessageFromIncomingEmail < Covered::Operation

  def call
    return if @email.project.nil?
    return if user.nil? && pre_existing_conversation.nil?

    send_message!
    return message
  end

  def send_message!
    SendConversationMessageWorker.enqueue(message_id: message.id)
  end

  let :attachments do
    @email.attachments.map do |attachment|
      StoreIncomingAttachment.call(attachment)
    end
  end

  let :from do
    @email.from.first
  end

  let :user do
    @email.project.members.with_email(from).first
  end

  let :pre_existing_conversation do
    @email.conversation
  end

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  let :type do
    if pre_existing_conversation
      pre_existing_conversation.task? ? :task : :conversation
    else
      @email.subject =~ TASK_SUBJECT_PREFIX_REGEXP ? :task : :conversation
    end
  end

  let :subject do
    if type == :task
      @email.subject.sub(TASK_SUBJECT_PREFIX_REGEXP, '')
    else
      @email.subject
    end
  end

  let :conversation do
    pre_existing_conversation || case type
    when :task
      @email.project.tasks.create(subject: subject, creator: user)
    when :conversation
      @email.project.conversations.create(subject: subject, creator: user)
    end
  end

  let :message do
    conversation.messages.create!(
      message_id_header: @email.header['Message-ID'].to_s,
      subject:           subject,
      parent_message:    @email.parent_message,
      user:              user,
      from:              from,
      body_plain:        strip_body(@email.text_part),
      body_html:         strip_body(@email.html_part),
      stripped_plain:    strip_body(@email.text_part_stripped),
      stripped_html:     strip_body(@email.html_part_stripped),
      attachments:       attachments,
    )
  end

  def strip_body(body)
    Covered.strip_user_specific_content_from_email_message_body(:body => body)
  end

end
