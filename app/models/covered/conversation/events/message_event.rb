class Covered::Conversation::Events::MessageEvent
  def initialize message
    @message = message
    @covered = message.covered
  end
  attr_reader :message

  def event_type
    'created_message'
  end

  def id
    "message-#{message.id}"
  end

  def content
    nil
  end

  def actor_id
    message.creator.present? ? message.creator.id : nil
  end

  def created_at
    message.date_header
  end

end
