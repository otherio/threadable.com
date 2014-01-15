class Covered::User::Organization::Conversations < Covered::Organization::Conversations

  def initialize organization
    super
    @user = organization.user
  end
  attr_reader :user

  def my
    conversations_for scope.
      joins('LEFT JOIN conversation_groups ON conversations.id = conversation_groups.conversation_id and conversation_groups.active = \'t\'').
      joins('LEFT JOIN group_memberships ON conversation_groups.group_id = group_memberships.group_id').
      where('(group_memberships.user_id = ? and conversation_groups.active = \'t\') or conversation_groups.group_id is null', user.user_id)
  end

end
