require_dependency 'covered/message'

class Covered::Message::Attachments < Covered::Attachments

  def initialize message
    @message = message
    @covered = message.covered
  end
  attr_reader :message

  private

  def scope
    message.message_record.attachments
  end

end
