require_dependency 'threadable/conversation'

class Threadable::Conversation::Participant < Threadable::Model

  def initialize conversation, user_record
    @conversation, @user_record = conversation, user_record
    @threadable = conversation.threadable
  end
  attr_reader :conversation, :user_record

  delegate *%w{
    id
    to_param
    name
    avatar_url
  }, to: :user_record

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class}>)
  end

end
