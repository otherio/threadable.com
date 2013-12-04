class Covered::IncomingEmail::Attachments

  def initialize incoming_email
    @incoming_email = incoming_email
  end
  attr_reader :incoming_email
  delegate :covered, to: :incoming_email

  def all
    scope.map{|attachment_record| attachment_for attachment_record }
  end

  def inspect
    %(#<#{self.class} incoming_email_id: #{incoming_email.id.inspect}>)
  end

  private

  def attachment_for attachment_record
    Covered::Attachment.new(covered, attachment_record)
  end

  def scope
    incoming_email.incoming_email_record.attachments.all
  end

end
