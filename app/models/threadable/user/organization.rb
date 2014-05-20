require_dependency 'threadable/user'

class Threadable::User::Organization < Threadable::Organization

  def initialize organizations, organization_record
    @threadable = organizations.threadable
    @organizations = organizations
    @organization_record = organization_record
    @user = organizations.user
  end
  attr_reader :organizations, :user

  let(:groups)          { Threadable::User::Organization::Groups.new self }
  let(:my_conversations){ Threadable::User::Organization::MyConversations.new self }
  let(:my_tasks)        { Threadable::User::Organization::MyTasks.new self }

  def leave!
    members.remove(user: user)
  end

  def confirm!
    organization_membership_record.update_attribute(:confirmed, true)
  end

  private

  def organization_membership_record
    organization_record.organization_memberships.where(user_id: user.id).first
  end
end

require_dependency 'threadable/user/organization/groups'
