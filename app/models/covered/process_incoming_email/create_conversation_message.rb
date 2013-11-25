class Covered::ProcessIncomingEmail::CreateConversationMessage < MethodObject

  TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  include Let

  def call covered, incoming_email
    @covered, @incoming_email = covered, incoming_email
    create_message!
  end
  attr_reader :covered, :incoming_email


  let :creator do
    user = covered.users.find_by_email_address! incoming_email.sender_email_address
    covered.current_user_id = user.id
    covered.current_user
  end

  let :project do
    creator.projects.find_by_email_address! incoming_email.recipient_email_address
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
      message_id_header: incoming_email.header['Message-ID'].to_s,
      subject:           subject,
      parent_message:    parent_message,
      from:              incoming_email.sender_email_address,
      body_plain:        body_plain,
      body_html:         body_html,
      stripped_plain:    stripped_plain,
      stripped_html:     stripped_html,
      attachments:       attachments,
    )
  end

  def strip_user_specific_content body
    StripUserSpecificContentFromEmailMessageBody.call body
  end




  # def send_message!
  #   covered.background_jobs.enqueue(:send_conversation_message, message_id: message.id)
  # end

  # let :attachments do
  #   incoming_email.attachments.map do |file|
  #     Attachment.create_from_file! file
  #   end
  # end

  # let :from do
  #   incoming_email.from.first
  # end

  # let :user do
  #   incoming_email.project.members.with_email(from).first
  # end

  # let :pre_existing_conversation do
  #   incoming_email.conversation
  # end

  # TASK_SUBJECT_PREFIX_REGEXP = /^(task:|✔)\s*/i

  # let :type do
  #   if pre_existing_conversation
  #     pre_existing_conversation.task? ? :task : :conversation
  #   else
  #     incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP ? :task : :conversation
  #   end
  # end

  # let :subject do
  #   if type == :task
  #     incoming_email.subject.sub(TASK_SUBJECT_PREFIX_REGEXP, '')
  #   else
  #     incoming_email.subject
  #   end
  # end

  # let :conversation do
  #   pre_existing_conversation || case type
  #   when :task
  #     incoming_email.project.tasks.create(subject: subject, creator: user)
  #   when :conversation
  #     incoming_email.project.conversations.create(subject: subject, creator: user)
  #   end
  # end

  # let :message do
  #   conversation.messages.create!(
  #     message_id_header: incoming_email.header['Message-ID'].to_s,
  #     subject:           subject,
  #     parent_message:    incoming_email.parent_message,
  #     user:              user,
  #     from:              from,
  #     body_plain:        strip_body(incoming_email.text_part),
  #     body_html:         strip_body(incoming_email.html_part),
  #     stripped_plain:    strip_body(incoming_email.text_part_stripped),
  #     stripped_html:     strip_body(incoming_email.html_part_stripped),
  #     attachments:       attachments,
  #   )
  # end

  # def strip_body(body)
  #   covered.strip_user_specific_content_from_email_message_body(:body => body)
  # end

end
