require_dependency 'threadable/user'

class Threadable::User::Organization < Threadable::Organization

  def initialize organizations, organization_record
    @threadable = organizations.threadable
    @organizations = organizations
    @organization_record = organization_record
    @user = organizations.user
  end
  attr_reader :organizations, :user

  let(:groups)                 { Threadable::User::Organization::Groups                 .new self }
  let(:ungrouped_conversations){ Threadable::User::Organization::UngroupedConversations .new self }

  def membership
    @membership ||= members.me
  end

  def leave!
    members.remove(user: user)
  end

  def inspect
    %(#{super[0..-2]} for_user: #{user.inspect}>)
  end

end

require_dependency 'threadable/user/organization/groups'
