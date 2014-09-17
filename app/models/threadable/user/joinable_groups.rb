require_dependency 'threadable/user/groups'

class Threadable::User::JoinableGroups < Threadable::User::Groups

  private

  def scope
    ::Group.
      joins(organization: :organization_memberships).
      where(private: false, organization_memberships: {user_id: user.user_id})
  end

end
