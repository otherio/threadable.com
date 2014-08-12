require_dependency 'threadable/user'

class Threadable::Organization::Member::Groups < Threadable::User::Groups

  def initialize member
    @user = member
    @organization = member.organization
  end

  attr_reader :organization

  private

  def scope
    organization.organization_record.groups.
      joins(:memberships).
      where(group_memberships: {user_id: user.user_id})
  end

end
