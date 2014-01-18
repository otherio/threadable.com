require_dependency 'covered/user'

class Covered::User::Organization < Covered::Organization

  def initialize organizations, organization_record
    @covered = organizations.covered
    @organizations = organizations
    @organization_record = organization_record
    @user = organizations.user
  end
  attr_reader :organizations, :user

  let(:groups)          { Covered::User::Organization::Groups.new self }
  let(:my_conversations){ Covered::User::Organization::MyConversations.new self }
  let(:my_tasks)        { Covered::User::Organization::MyTasks.new self }

  def leave!
    members.remove(user: user)
  end

end

require_dependency 'covered/user/organization/groups'
