class Covered::IncomingEmail::Attachments < Covered::Attachments

  def initialize incoming_email
    super(incoming_email.covered)
    @incoming_email = incoming_email
  end
  attr_reader :incoming_email

  # create(filename: 'cat.jpg', mimetype: 'image/jpg', content: "CONTENT")
  def create attributes
    Create.call(self, attributes)
  end

  def inspect
    %(#<#{self.class} incoming_email_id: #{incoming_email.id.inspect}>)
  end

  private

  def scope
    incoming_email.incoming_email_record.attachments
  end

end
