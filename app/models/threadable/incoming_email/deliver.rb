# Encoding: UTF-8

require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::Deliver < MethodObject

  def call incoming_email
    @incoming_email = incoming_email
    Threadable.transaction do
      create_or_update_conversation!
      if @incoming_email.message.present?
        delete_attachments!
        @incoming_email.message.send_emails!
      else
        save_off_attachments!
        call_webhook!
        create_message!
      end
      save!
    end
  end

  def save_off_attachments!
    return unless @incoming_email.params.key?('attachment-count')

    content_id_map = @incoming_email.params["content-id-map"]
    content_ids = content_id_map.present? ? JSON.parse(content_id_map).invert : {}

    1.upto(@incoming_email.params.delete('attachment-count').to_i).map do |n|
      file = @incoming_email.params.delete("attachment-#{n}")
      @incoming_email.attachments.create!(
        filename:   file.filename,
        mimetype:   file.mimetype,
        content:    file.read,
        content_id: content_ids["attachment-#{n}"],
      )
    end
  end

  def delete_attachments!
    1.upto(@incoming_email.params.delete('attachment-count').to_i).map do |n|
      @incoming_email.params.delete("attachment-#{n}")
    end
  end

  def create_or_update_conversation!
    @incoming_email.conversation.present? ? update_conversation! : create_conversation!
  end

  # believe it or not, these three checkmarks are different!
  TASK_SUBJECT_PREFIX_REGEXP = /^\[(✔|✔\uFE0E|✔\uFE0F|task)\]\s*/i
  TASK_RECIPIENT_REGEXP = /(\+|--)task\b/i
  def create_conversation!
    is_task = @incoming_email.subject =~ TASK_SUBJECT_PREFIX_REGEXP || @incoming_email.recipient =~ TASK_RECIPIENT_REGEXP
    collection = (is_task ? @incoming_email.organization.tasks : @incoming_email.organization.conversations)
    @incoming_email.conversation = collection.create!(
      subject:    subject,
      creator_id: @incoming_email.creator.try(:id),
      groups:     @incoming_email.groups,
    )
  end

  def update_conversation!
    @incoming_email.conversation.groups.add_unless_removed(*@incoming_email.groups)
  end

  def call_webhook!
    url = @incoming_email.groups.find(&:has_webhook?).try(:webhook_url) or return
    Threadable::IncomingEmail::ProcessWebhook.call(@incoming_email, url)
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
      body_plain:        strip_threadable_content(@incoming_email.body_plain),
      body_html:         strip_threadable_content(@incoming_email.body_html),
      stripped_plain:    strip_threadable_content(@incoming_email.stripped_plain),
      stripped_html:     strip_threadable_content(@incoming_email.stripped_html),
      attachments:       @incoming_email.attachments.all,
    )
  end

  def subject
    PrepareEmailSubject.call(@incoming_email.organization, @incoming_email)
  end

  def save!
    @incoming_email.save!
  end

  def strip_threadable_content body
    StripThreadableContentFromEmailMessageBody.call(body) unless body.nil?
  end

  def send_emails!
    @message.recipients.all.each do |recipient|
      next if recipient.same_user?(creator)
      @threadable.emails.send_email_async(:conversation_message, recipient.id, @conversation.organization.id, @message.id)
    end
  end

end
