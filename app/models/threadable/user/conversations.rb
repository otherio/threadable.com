require_dependency 'threadable/user'

class Threadable::User::Conversations < Threadable::Conversations

  def initialize user
    @user = user
  end

  attr_reader :user
  delegate :threadable, to: :user

  def inspect
    %(#<#{self.class} for_user: #{user.inspect}>)
  end

  private

  def scope
    user.user_record.conversations
  end

end
