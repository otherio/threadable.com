require_dependency 'threadable/user'

class Threadable::User::Groups < Threadable::Groups

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
    ::Group.joins(organization: :organization_memberships).where(organization_memberships: {user_id: user.user_id})
  end

end
