class Covered::Project::Conversation::Message::Attachment

  def initialize message, attachment_record
    @message, @attachment_record = message, attachment_record
  end
  attr_reader :message, :attachment_record
  delegate :covered, to: :message

  delegate *%w{
    url
    filename
    mimetype
    size
    writeable?
    content
  }, to: :attachment_record

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class}>)
  end

end
