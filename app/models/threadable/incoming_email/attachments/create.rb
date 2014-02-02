require_dependency 'threadable/incoming_email/attachments'

class Threadable::IncomingEmail::Attachments::Create < MethodObject

  def call attachments, attributes
    @attachments = attachments
    @threadable     = attachments.threadable

    @attachment = Threadable::Attachments::Create.call(attachments, attributes)
    @attachment.persisted? or raise Threadable::RecordInvalid, "Attachment invalid: #{@attachment.errors.full_messages.to_sentence}"
    @attachments.incoming_email.incoming_email_record.attachments << @attachment.attachment_record
    @attachment
  end

end
