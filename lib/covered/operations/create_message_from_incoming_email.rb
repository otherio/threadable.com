Covered::Operations.define :create_message_from_incoming_email do

  option :incoming_email_id, required: true

  let(:incoming_email){ Covered::IncomingEmail.find incoming_email_id }

  def call
    if incoming_email.project.nil?
      raise "unabled to find project for incoming email #{incoming_email.id}"
    end
    if user.nil? && pre_existing_conversation.nil?
      raise "unable to find a user or a pre existing conversation for incoming email #{incoming_email.id}"
    end

    send_message!
    message
  end

  def send_message!
    covered.background_jobs.enqueue(:send_conversation_message, message_id: message.id)
  end

  let :attachments do
    incoming_email.attachments.map do |file|
      Covered::Attachment.create_from_file! file
    end
  end

  let :from do
    incoming_email.from.first
  end

  let :user do
    incoming_email.project.members.with_email(from).first
  end

  let :pre_existing_conversation do
    incoming_email.conversation
  end

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  let :type do
    if pre_existing_conversation
      pre_existing_conversation.task? ? :task : :conversation
    else
      incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP ? :task : :conversation
    end
  end

  let :subject do
    if type == :task
      incoming_email.subject.sub(TASK_SUBJECT_PREFIX_REGEXP, '')
    else
      incoming_email.subject
    end
  end

  let :conversation do
    pre_existing_conversation || case type
    when :task
      incoming_email.project.tasks.create(subject: subject, creator: user)
    when :conversation
      incoming_email.project.conversations.create(subject: subject, creator: user)
    end
  end

  let :message do
    conversation.messages.create!(
      message_id_header: incoming_email.header['Message-ID'].to_s,
      subject:           subject,
      parent_message:    incoming_email.parent_message,
      user:              user,
      from:              from,
      body_plain:        strip_body(incoming_email.text_part),
      body_html:         strip_body(incoming_email.html_part),
      stripped_plain:    strip_body(incoming_email.text_part_stripped),
      stripped_html:     strip_body(incoming_email.html_part_stripped),
      attachments:       attachments,
    )
  end

  def strip_body(body)
    covered.strip_user_specific_content_from_email_message_body(:body => body)
  end

end
