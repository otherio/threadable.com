# Encoding: UTF-8

require_dependency 'covered/incoming_email'

class Covered::IncomingEmail::Deliver < MethodObject

  def call incoming_email
    @incoming_email = incoming_email
    Covered.transaction do
      save_off_attachments!
      create_conversation! unless @incoming_email.conversation.present?
      create_message!
      save!
    end
  end

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

  TASK_SUBJECT_PREFIX_REGEXP = /^\[(✔|task)\]\s*/i
  TASK_RECIPIENT_REGEXP = /\+task\b/i
  def create_conversation!
    is_task = @incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP || @incoming_email.recipient =~ TASK_RECIPIENT_REGEXP
    collection = (is_task ? @incoming_email.project.tasks : @incoming_email.project.conversations)
    @incoming_email.conversation = collection.create!(
      subject:    subject,
      creator_id: @incoming_email.creator.try(:id),
    )
  end

  def create_message!
    @incoming_email.message = @incoming_email.conversation.messages.create!(
      creator_id:        @incoming_email.creator.try(:id),
      message_id_header: @incoming_email.message_id,
      references_header: @incoming_email.references,
      date_header:       @incoming_email.date.rfc2822,
      to_header:         @incoming_email.to,
      cc_header:         @incoming_email.cc,
      subject:           @incoming_email.subject[0..254],
      parent_message:    @incoming_email.parent_message,
      from:              @incoming_email.from,
      body_plain:        strip_user_specific_content(@incoming_email.body_plain),
      body_html:         strip_user_specific_content(@incoming_email.body_html),
      stripped_plain:    strip_user_specific_content(@incoming_email.stripped_plain),
      stripped_html:     strip_user_specific_content(@incoming_email.stripped_html),
      attachments:       @incoming_email.attachments,
    )
  end

  def subject
    PrepareEmailSubject.call(@incoming_email.project, @incoming_email)
  end

  def save!
    @incoming_email.save!
  end

  def strip_user_specific_content body
    StripUserSpecificContentFromEmailMessageBody.call(body) unless body.nil?
  end

end
