class Covered::Project::Conversation::Recipient

  def initialize conversation, user_record
    @conversation, @user_record = conversation, user_record
  end
  attr_reader :conversation, :user_record
  delegate :covered, to: :conversation

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
