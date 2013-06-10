class EmailProcessor < MethodObject.new(:email_data)

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Multify.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Multify.config('mailgun')['key']
  end

  def self.encode_attachements(email_data)
    1.upto(email_data['attachment-count'].to_i).each do |n|
      attachment = email_data["attachment-#{n}"]
      email_data["attachment-#{n}"] = {
        "original_filename" => attachment.original_filename,
        "read" =>  attachment.read,
      }
    end
  end

  Attachent = Struct.new(:original_filename, :read)

  def self.decode_attachements(email_data)
    1.upto(email_data['attachment-count'].to_i).each do |n|
      attachment = email_data["attachment-#{n}"]
      email_data["attachment-#{n}"] = Attachent.new(attachment["original_filename"], attachment["read"])
    end
  end

  Request = Struct.new(:params)

  def call
    self.class.decode_attachements(@email_data)
    request = Request.new(@email_data)
    @email = MailgunRequestToEmail.new(request).message
    @email_stripped = MailgunRequestToEmailStripped.new(request).message

    return if project.nil?
    return if !known_user? && !known_conversation?

    @attachments = @email.attachments.map do |attachment|
      StoreIncomingAttachment.call(project.slug, attachment.filename, attachment.body.decoded, attachment.content_type)
    end

    dispatch!
    conversation_message
  end

  def dispatch!
    SendConversationMessageWorker.enqueue(message_id: conversation_message.id)
  end

  def multify_project_slug
    @multify_project_slug ||= EmailProcessor::ProjectSlugFinder.call(@email.to) or raise "No project slug"
  end

  def from
    @email.from.first
  end

  def project
    @project ||= Project.find_by_slug multify_project_slug
  end

  def known_user?
    user.present?
  end

  def user
    @user ||= project.members.find_by_email from
  end

  def parent_message
    @parent_message ||= ParentMessageFinder.call(project.id, @email.header)
  end

  def known_conversation?
    pre_existing_conversation.present?
  end

  def pre_existing_conversation
    parent_message.conversation if parent_message
  end

  def conversation
    @conversation ||= pre_existing_conversation || project.conversations.create(subject: @email.subject, creator: user)
  end

  def conversation_message
    @conversation_message ||= conversation.messages.create!(
      message_id_header: @email.header['Message-ID'].to_s,
      subject: @email.subject,
      parent_message: parent_message,
      user: user,
      from: from,
      body_plain: filter_token(@email.text_part),
      body_html: filter_token(@email.html_part),
      stripped_plain: filter_token(@email_stripped.text_part),
      stripped_html: filter_token(@email_stripped.html_part),
      attachments: @attachments,
    )
  end

  private

  def filter_token(part)
    EmailProcessor::UnsubscribeTokenFilterer.call(part.body)
  end

end
