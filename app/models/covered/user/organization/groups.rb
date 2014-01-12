class Covered::User::Organization::Groups < Covered::Organization::Groups

  def initialize organization
    super
    @user = organization.user
  end
  attr_reader :user

  def my
    groups_for scope.joins(:group_members).where(group_memberships:{ user_id: user.user_id })
  end

end
