class Covered::Project::CreateMessageFromIncomingEmail < MethodObject

  include Let

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < ::Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Covered.config('mailgun')['key']
  end




  def call covered, incoming_email
    @covered, @incoming_email = covered, incoming_email
    become_from_user!

    create_message!
    send_message!
  end




  def become_from_user!
    user = @covered.users.find_by_email_address! @incoming_email.from
    @covered.current_user_id = user.id

  end

  def become_from_user!
    @covered.current_user_id =

  end

  def create_message!
    @message = conversation.messages.create!(
      message_id_header: @incoming_email.header['Message-ID'].to_s,
      subject:           subject,
      parent_message:    @incoming_email.parent_message,
      user:              user,
      from:              from,
      body_plain:        strip_body(@incoming_email.text_part),
      body_html:         strip_body(@incoming_email.html_part),
      stripped_plain:    strip_body(@incoming_email.text_part_stripped),
      stripped_html:     strip_body(@incoming_email.html_part_stripped),
      attachments:       attachments,
    )
  end

  def send_message!
    # covered.background_jobs.enqueue(:send_conversation_message, message_id: message.id)

    message
  end

  let :user do
    @incoming_email.project.members.with_email_address(from).first!
  end

  let :pre_existing_conversation do
    @incoming_email.conversation
  end

  let :attachments do
    @incoming_email.attachments.map do |file|
      Attachment.create_from_file! file
    end
  end

  let :from do
    @incoming_email.from.first
  end

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  let :type do
    if pre_existing_conversation
      pre_existing_conversation.task? ? :task : :conversation
    else
      @incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP ? :task : :conversation
    end
  end

  let :subject do
    if type == :task
      @incoming_email.subject.sub(TASK_SUBJECT_PREFIX_REGEXP, '')
    else
      @incoming_email.subject
    end
  end

  let :conversation do
    pre_existing_conversation || case type
    when :task
      @incoming_email.project.tasks.create(subject: subject, creator: user)
    when :conversation
      @incoming_email.project.conversations.create(subject: subject, creator: user)
    end
  end

  def strip_body(body)
    covered.strip_user_specific_content_from_email_message_body(:body => body)
  end


end
