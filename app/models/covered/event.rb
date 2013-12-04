class Covered::Event < Covered::Model

  def initialize covered, event_record
    @covered, @event_record = covered, event_record
  end

  delegate *%w{
    id
    type
    project_id
    conversation_id
    user_id
    content
    created_at
  }, to: :attachment_record

  def inspect
    %(#<#{self.class} id: #{id.inspect}>)
  end

end
