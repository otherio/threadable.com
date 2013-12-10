class Covered::Attachments < Covered::Collection

  def all
    scope.reload.map{ |attachment_record| attachment_for attachment_record }
  end
  alias_method :to_a, :all

  def build attributes
    attachment_for scope.build(attributes)
  end
  alias_method :new, :build

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

end
