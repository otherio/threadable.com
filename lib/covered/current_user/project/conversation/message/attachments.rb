class Covered::CurrentUser::Project::Conversation::Message::Attachments

  def initialize message
    @message = message
  end
  attr_reader :message
  delegate :covered, to: :message

  def all
    scope.map{ |attachment| attachment_for attachment }
  end

  def count
    scope.count
  end

  def build attributes
    attachment_for scope.build(attributes)
  end
  alias_method :new, :build


  def as_json options=nil
    all.as_json(options)
  end

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    message.message_record.attachments
  end

  def attachment_for attachment_record
    Covered::CurrentUser::Project::Conversation::Message::Attachment.new(message, attachment_record)
  end

end

require 'covered/current_user/project/conversation/message/attachment'
