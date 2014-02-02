require_dependency 'threadable/user'

class Threadable::User::Messages < Threadable::Messages

  def initialize user
    @user = user
  end

end
