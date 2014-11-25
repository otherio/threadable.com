require_dependency 'threadable/user'

class Threadable::User::Messages < Threadable::Messages

  def initialize user
    @user = user
  end

  attr_reader :user

  def scope
    user.user_record.messages.all
  end

end
