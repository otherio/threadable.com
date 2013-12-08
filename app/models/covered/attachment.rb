class Covered::Attachment

  def initialize covered, attachment_record
    @covered, @attachment_record = covered, attachment_record
  end
  attr_reader :covered, :attachment_record

  delegate *%w{
    id
    url
    filename
    mimetype
    size
    content
    writeable?
    created_at
    updated_at
    errors
    persisted?
  }, to: :attachment_record

  def inspect
    %(#<#{self.class} attachment_id: #{id.inspect} url: #{url.inspect}>)
  end

end
