class Covered::Project::Task::Event < Covered::Project::Conversation::Event

  alias_method :task, :conversation

  def as_json options=nil
    {
      type:     human_readable_type,
      actor_id: actor_id,
      task_id:  task.id,
    }
  end

end
