class Threadable::Conversation::Events::MessageEvent
  def initialize message
    @message = message
    @threadable = message.threadable
  end
  attr_reader :message

  def event_type
    :created_message
  end

  def id
    "message-#{message.id}"
  end

  def actor
    message.creator
  end

  def created_at
    message.sent_at
  end

end
