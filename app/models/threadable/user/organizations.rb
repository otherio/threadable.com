require_dependency 'threadable/user'

class Threadable::User::Organizations < Threadable::Organizations

  def initialize user
    @user = user
  end

  attr_reader :user
  delegate :threadable, to: :user

  def inspect
    %(#{super[0..-2]} for_user: #{user.inspect}>)
  end

  private

  def scope
    user.user_record.organizations
  end

end
