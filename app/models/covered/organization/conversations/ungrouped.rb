class Covered::Organization::Conversations::Ungrouped < Covered::Organization::Conversations

  private

  def scope
    super.unload.
      joins('LEFT JOIN conversation_groups ON conversation_groups.conversation_id = conversations.id').
      where(conversation_groups:{conversation_id:nil})
  end

end
