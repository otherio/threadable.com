require_dependency 'threadable/user'

class Threadable::User::Groups < Threadable::Groups

  def initialize user
    @user = user
  end

  def with_summary
    groups_for scope.joins(:memberships).where(group_memberships: {summary: true, user_id: user.user_id})
  end

  attr_reader :user
  delegate :threadable, to: :user

  def inspect
    %(#<#{self.class} for_user: #{user.inspect}>)
  end

  private

  def scope
    ::Group.joins(organization: :organization_memberships).where(organization_memberships: {user_id: user.user_id})
  end

end
