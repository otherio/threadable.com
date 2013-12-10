require_dependency 'covered/incoming_email'

class Covered::IncomingEmail::Process < MethodObject

  def call incoming_email
    @incoming_email, @covered = incoming_email, incoming_email.covered
    raise ArgumentError, "IncomingEmail #{@incoming_email.id.inspect} was already processed. Call reset! first." if incoming_email.processed?
    ActiveRecord::Base.transaction do
      find_message_by_message_id_header!
      save_off_attachments!
      find_project!
      find_creator!
      find_parent_message!
      find_or_create_conversation!
      find_or_create_message!
      @incoming_email.incoming_email_record.processed! !!@incoming_email.message_id
      @incoming_email.incoming_email_record.save!
    end
  end

  # we're doing this to shrink our incoming messages table size
  def save_off_attachments!
    return unless @incoming_email.params.key?('attachment-count')
    1.upto(@incoming_email.params.delete('attachment-count').to_i).map do |n|
      file = @incoming_email.params.delete("attachment-#{n}")
      @incoming_email.attachments.create!(
        filename: file.filename,
        mimetype: file.mimetype,
        content:  file.read,
      )
    end
  end


  def find_project!
    return if @incoming_email.project_id
    @project = @covered.projects.find_by_email_address @incoming_email.recipient_email_address
    @incoming_email.project_id = @project.id if @project
  end

  def find_creator!
    return if @incoming_email.creator_id
    @incoming_email.from_email_addresses.find do |email_address|
      user = @covered.users.find_by_email_address(email_address) or next
      @incoming_email.creator_id = user.id
      break
    end
  end

  def find_parent_message!
    return if @incoming_email.parent_message_id || @incoming_email.project_id.nil?
    @project ||= @covered.projects.find_by_id!(@incoming_email.project_id)
    parent_message = @project.messages.find_by_child_message_header(@incoming_email.header) or return
    @incoming_email.parent_message_id = parent_message.id
    @incoming_email.conversation_id   = parent_message.conversation_id
  end

  TASK_SUBJECT_PREFIX_REGEXP = /^\[(✔|task)\]\s*/i
  TASK_RECIPIENT_REGEXP = /\+task\b/i
  def find_or_create_conversation!
    return if @incoming_email.conversation_id || @incoming_email.project_id.nil?
    @project ||= @covered.projects.find_by_id!(@incoming_email.project_id)

    if @incoming_email.parent_message
      @conversation = @incoming_email.parent_message.conversation
      @incoming_email.conversation_id = @conversation.id
      return
    end

    return if @incoming_email.creator_id.nil?

    is_task = @incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP || @incoming_email.recipient_email_address =~ TASK_RECIPIENT_REGEXP

    subject = StripEmailSubject.call(@project, @incoming_email.subject)

    @conversation = (is_task ? @project.tasks : @project.conversations).create!(
      subject:    subject[0..254],
      creator_id: @incoming_email.creator_id,
    )

    @incoming_email.conversation_id = @conversation.id
  end

  def find_or_create_message!
    return if @incoming_email.message_id || @incoming_email.conversation_id.nil? || @incoming_email.project_id.nil?
    @project ||= @covered.projects.find_by_id!(@incoming_email.project_id)
    @conversation ||= @project.conversations.find_by_id!(@incoming_email.conversation_id)
    # this is where we prevent non-members from starting new conversations
    return if @incoming_email.creator_id.nil? && @incoming_email.parent_message_id.nil?
    @message ||= @conversation.messages.create!(
      creator_id:        @incoming_email.creator_id,
      message_id_header: @incoming_email.message_id_header,
      references_header: @incoming_email.references_header,
      date_header:       @incoming_email.date_header,
      to_header:         @incoming_email.to_header,
      cc_header:         @incoming_email.cc_header,
      subject:           @incoming_email.subject[0..254],
      parent_message:    @incoming_email.parent_message,
      from:              @incoming_email.from_email_address,
      body_plain:        strip_user_specific_content(@incoming_email.body_plain),
      body_html:         strip_user_specific_content(@incoming_email.body_html),
      stripped_plain:    strip_user_specific_content(@incoming_email.stripped_plain),
      stripped_html:     strip_user_specific_content(@incoming_email.stripped_html),
      attachments:       @incoming_email.attachments,
    )
    @incoming_email.message_id = @message.id
  end

  # this is here for legacy reasons
  def find_message_by_message_id_header!
    return if @incoming_email.message_id
    @message = @covered.messages.find_by_message_id_header(@incoming_email.message_id_header) or return
    @project = @message.project
    @conversation = @message.conversation
    @incoming_email.message_id        = @message.id
    @incoming_email.conversation_id   = @conversation.id
    @incoming_email.project_id        = @project.id
    @incoming_email.parent_message_id = @message.parent_message_id
  end

  def strip_user_specific_content body
    StripUserSpecificContentFromEmailMessageBody.call(body) unless body.nil?
  end

end
