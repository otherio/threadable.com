class Threadable::Attachment < Threadable::Model

  def initialize threadable, attachment_record
    @threadable, @attachment_record = threadable, attachment_record
  end
  attr_reader :threadable, :attachment_record

  delegate *%w{
    id
    url
    filename
    mimetype
    size
    content
    inline?
    writeable?
    created_at
    updated_at
    errors
    persisted?
    content_id
  }, to: :attachment_record

  def inspect
    %(#<#{self.class} attachment_id: #{id.inspect} url: #{url.inspect}>)
  end

end
