class EmailProcessor < MethodObject.new(:incoming_email)

  include Let

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Covered.config('mailgun')['key']
  end

  attr_reader :incoming_email
  def call
    return if project.nil?
    return if user.nil? && pre_existing_conversation.nil?

    dispatch!
    message
  end

  def dispatch!
    SendConversationMessageWorker.enqueue(message_id: message.id)
  end

  let :attachments do
    email.attachments.map do |attachment|
      StoreIncomingAttachment.call(attachment)
    end
  end

  let :email do
    MailgunRequestToEmail.new(incoming_email).message
  end

  let :email_stripped do
    MailgunRequestToEmailStripped.new(incoming_email).message
  end

  let :project_email_address_username do
    EmailProcessor::ProjectEmailAddressUsernameFinder.call(email.to)
  end

  let :from do
    email.from.first
  end

  let :project do
    Project.where(email_address_username: project_email_address_username).first if \
      project_email_address_username.present?
  end

  let :user do
    project.members.with_email(from).first
  end

  let :parent_message do
    ParentMessageFinder.call(project.id, email.header)
  end

  let :pre_existing_conversation do
    parent_message.conversation if parent_message
  end

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  let :type do
    if pre_existing_conversation
      pre_existing_conversation.task? ? :task : :conversation
    else
      email.subject =~ TASK_SUBJECT_PREFIX_REGEXP ? :task : :conversation
    end
  end

  let :subject do
    if type == :task
      email.subject.sub(TASK_SUBJECT_PREFIX_REGEXP, '')
    else
      email.subject
    end
  end

  let :conversation do
    pre_existing_conversation || case type
    when :task
      project.tasks.create(subject: subject, creator: user)
    when :conversation
      project.conversations.create(subject: subject, creator: user)
    end
  end

  let :message do
    conversation.messages.create!(
      message_id_header: email.header['Message-ID'].to_s,
      subject: subject,
      parent_message: parent_message,
      user: user,
      from: from,
      body_plain: filter_unsubscribe_token(email.text_part),
      body_html: filter_unsubscribe_token(email.html_part),
      stripped_plain: filter_unsubscribe_token(email_stripped.text_part),
      stripped_html: filter_unsubscribe_token(email_stripped.html_part),
      attachments: attachments,
    )
  end

  private

  def filter_unsubscribe_token(part)
    body = EmailProcessor::UnsubscribeTokenFilterer.call(part.body)
    EmailProcessor::FooterFilterer.call(body)
  end

end
