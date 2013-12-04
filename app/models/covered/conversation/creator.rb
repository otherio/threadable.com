class Covered::Conversation::Creator

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def user_record
    @user_record ||= conversation.conversation_record.creator
  end

  delegate *%w{
    id
    name
    slug
  }, to: :user_record

  alias_method :user_id, :id

  def == other
    other.respond_to?(:user_id) && self.user_id == other.user_id
  end

  def inspect
    %(#<#{self.class} user_id: #{user_id.inspect}>)
  end

end
