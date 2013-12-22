require_dependency 'covered/user'

class Covered::User::Organization < Covered::Organization

  def initialize organizations, organization_record
    @covered = organizations.covered
    @organizations = organizations
    @organization_record = organization_record
  end
  attr_reader :organizations

  def leave!
    members.remove(user: organizations.user)
  end

end
