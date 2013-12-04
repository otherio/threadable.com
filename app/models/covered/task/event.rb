class Covered::Task::Event < Covered::Conversation::Event

  def as_json options=nil
    {
      type:     human_readable_type,
      actor_id: actor_id,
      task_id:  conversation_id,
    }
  end

end
