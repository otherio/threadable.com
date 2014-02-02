require_dependency 'threadable/message'

class Threadable::Message::Attachments < Threadable::Attachments

  def initialize message
    @message = message
    @threadable = message.threadable
  end
  attr_reader :message

  private

  def scope
    message.message_record.attachments
  end

end
