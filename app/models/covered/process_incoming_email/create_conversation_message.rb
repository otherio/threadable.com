class Covered::ProcessIncomingEmail::CreateConversationMessage < MethodObject

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  include Let

  def call covered, incoming_email
    @covered, @incoming_email = covered, incoming_email
    return bounce_message! if project.nil?
    return hold_message!   if creator.nil? && parent_message.nil?
    create_message!
  end
  attr_reader :covered, :incoming_email


  let :creator do
    user = covered.users.find_by_email_address(incoming_email.sender_email_address)
    user ||= covered.users.find_by_email_address(incoming_email.from_email_address)
    if user
      covered.current_user_id = user.id
      covered.current_user
    end
  end

  let :project do
    (creator || covered).projects.find_by_email_address incoming_email.recipient_email_address
  end

  let :parent_message do
    project.messages.find_by_child_message_header incoming_email.header
  end

  let :pre_existing_conversation do
    parent_message.conversation if parent_message
  end


  let :conversation do
    pre_existing_conversation || create_conversation!
  end

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
      project.tasks.create(subject: subject)
    when :conversation
      project.conversations.create(subject: subject)
    end
  end

  let :attachments do
    incoming_email.attachments.map do |file|
      Attachment.create_from_file! file
    end
  end

  let(:body_plain    ){ strip_user_specific_content incoming_email.body_plain     }
  let(:body_html     ){ strip_user_specific_content incoming_email.body_html      }
  let(:stripped_html ){ strip_user_specific_content incoming_email.stripped_html  }
  let(:stripped_plain){ strip_user_specific_content incoming_email.stripped_plain }

  def create_message!
    conversation.messages.create!(
      message_id_header: incoming_email.message_id_header,
      references_header: incoming_email.references_header,
      date_header:       incoming_email.date_header,
      subject:           subject,
      parent_message:    parent_message,
      from:              incoming_email.from_email_address,
      body_plain:        body_plain,
      body_html:         body_html,
      stripped_plain:    stripped_plain,
      stripped_html:     stripped_html,
      attachments:       attachments,
    )
  end

  def bounce_message!
    # covered.emails.send_email(:bounce)
  end

  def hold_message!
    # TODO
  end

  def strip_user_specific_content body
    StripUserSpecificContentFromEmailMessageBody.call(body) unless body.nil?
  end

end
