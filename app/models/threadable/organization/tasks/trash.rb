class Threadable::Organization::Tasks::Trash < Threadable::Organization::Tasks

  private

  def scope
    raise 'there is no current user' unless threadable.current_user_id
    super.trashed.
      joins('LEFT JOIN conversation_groups ON conversations.id = conversation_groups.conversation_id and conversation_groups.active = \'t\'').
      joins('LEFT JOIN group_memberships ON conversation_groups.group_id = group_memberships.group_id').
      where('(group_memberships.user_id = ? and conversation_groups.active = \'t\') or conversation_groups.group_id is null', threadable.current_user_id)
  end


end
