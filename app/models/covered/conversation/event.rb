require_dependency 'covered/conversation'

class Covered::Conversation::Event < Covered::Event

  def initialize covered, event_record, conversation=nil
    super(covered, event_record)
    @conversation = conversation
  end

end
