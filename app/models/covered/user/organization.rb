require_dependency 'covered/user'

class Covered::User::Organization < Covered::Organization

  def initialize organizations, organization_record
    @covered = organizations.covered
    @organizations = organizations
    @organization_record = organization_record
    @user = organizations.user
  end
  attr_reader :organizations, :user

  let(:conversations){ Covered::User::Organization::Conversations.new(self) }
  let(:groups)       { Covered::User::Organization::Groups.new self }

  def leave!
    members.remove(user: user)
  end

end

require_dependency 'covered/user/organization/conversations'
require_dependency 'covered/user/organization/groups'
