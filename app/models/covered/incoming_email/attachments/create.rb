require_dependency 'covered/incoming_email/attachments'

class Covered::IncomingEmail::Attachments::Create < MethodObject

  def call attachments, attributes
    @attachments = attachments
    @covered     = attachments.covered

    @attachment = Covered::Attachments::Create.call(attachments, attributes)
    @attachment.persisted? or raise Covered::RecordInvalid, "Attachment invalid: #{@attachment.errors.full_messages.to_sentence}"
    @attachments.incoming_email.incoming_email_record.attachments << @attachment.attachment_record
    @attachment
  end

end
