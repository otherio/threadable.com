require_dependency 'covered/user'

class Covered::User::Messages < Covered::Messages

  def initialize user
    @user = user
  end

end
