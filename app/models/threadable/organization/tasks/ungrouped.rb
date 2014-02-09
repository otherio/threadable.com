class Threadable::Organization::Tasks::Ungrouped < Threadable::Organization::Tasks

  private

  def scope
    super.unload.
      joins("LEFT JOIN conversation_groups ON conversation_groups.conversation_id = conversations.id and conversation_groups.active = 't'").
      where(conversation_groups:{conversation_id:nil})
  end

end
