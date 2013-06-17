class EmailProcessor < MethodObject.new(:incoming_email)

  include Let

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Multify.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Multify.config('mailgun')['key']
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
      StoreIncomingAttachment.call(project.slug, attachment)
    end
  end

  let :email do
    MailgunRequestToEmail.new(incoming_email).message
  end

  let :email_stripped do
    MailgunRequestToEmailStripped.new(incoming_email).message
  end

  let :multify_project_slug do
    EmailProcessor::ProjectSlugFinder.call(email.to) or raise "No project slug"
  end

  let :from do
    email.from.first
  end

  let :project do
    Project.find_by_slug multify_project_slug
  end

  let :user do
    project.members.find_by_email from
  end

  let :parent_message do
    ParentMessageFinder.call(project.id, email.header)
  end

  let :pre_existing_conversation do
    parent_message.conversation if parent_message
  end

  let :conversation do
    pre_existing_conversation || project.conversations.create(subject: email.subject, creator: user)
  end

  let :message do
    conversation.messages.create!(
      message_id_header: email.header['Message-ID'].to_s,
      subject: email.subject,
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
    EmailProcessor::UnsubscribeTokenFilterer.call(part.body)
  end

end
