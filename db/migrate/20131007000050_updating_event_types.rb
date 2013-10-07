class UpdatingEventTypes < ActiveRecord::Migration
  def change

    map = {
      :conversation_event=>"Conversation::Event",
      :task_event=>"Task::Event",
      :conversation_created_event=>"Conversation::CreatedEvent",
      :task_created_event=>"Task::CreatedEvent",
      :task_done_event=>"Task::DoneEvent",
      :task_undone_event=>"Task::UndoneEvent",
      :task_added_doer_event=>"Task::AddedDoerEvent",
      :task_removed_doer_event=>"Task::RemovedDoerEvent"
    }

    map.each do |old_type, new_type|
      Event.where(type:old_type).update_all(type:new_type)
    end

  end
end
