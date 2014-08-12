require_dependency 'threadable/user/groups'

class Threadable::User::AccessibleGroups < Threadable::User::Groups

  private

  def scope
    ::Group.
      joins(organization: :organization_memberships).
      where(organization_memberships: {user_id: user.user_id})
  end

end
