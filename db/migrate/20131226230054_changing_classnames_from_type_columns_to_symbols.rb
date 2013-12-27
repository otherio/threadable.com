class ChangingClassnamesFromTypeColumnsToSymbols < ActiveRecord::Migration

  RENAMES = {
    "Conversation::CreatedEvent" => "conversation_created",
    "Task::CreatedEvent"         => "task_created",
    "Task::DoneEvent"            => "task_done",
    "Task::AddedDoerEvent"       => "task_added_doer",
    "Task::UndoneEvent"          => "task_undone",
    "Task::RemovedDoerEvent"     => "task_removed_doer",
  }

  def up
    Event.transaction do
      Event.where(type: nil).delete_all
      RENAMES.each do |old, new|
        Event.where(type: old).update_all(type: new)
      end
      rename_column :events, :type, :event_type
    end
  end

  def down
    Event.transaction do
      rename_column :events, :event_type, :type
      Event.where(type: nil).delete_all
      RENAMES.each do |old, new|
        Event.where(type: new).update_all(type: old)
      end
    end
  end

end






