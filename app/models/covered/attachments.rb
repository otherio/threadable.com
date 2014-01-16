class Covered::Attachments < Covered::Collection

  def all
    attachments_for scope
  end

  # create(filename: 'cat.jpg', mimetype: 'image/jpg', content: "CONTENT")
  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    attachment = create(attributes)
    attachment.persisted? or raise Covered::RecordInvalid, "Attachment invalid: #{attachment.errors.full_messages.to_sentence}"
    attachment
  end

  private

  def scope
    ::Attachment.all
  end

  def attachment_for attachment_record
    Covered::Attachment.new(covered, attachment_record)
  end

  def attachments_for attachment_records
    attachment_records.map{ |attachment_record| attachment_for attachment_record }
  end

end
