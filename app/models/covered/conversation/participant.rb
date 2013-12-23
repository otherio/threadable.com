require_dependency 'covered/conversation'

class Covered::Conversation::Participant < Covered::Model

  def initialize conversation, user_record
    @conversation, @user_record = conversation, user_record
    @covered = conversation.covered
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
