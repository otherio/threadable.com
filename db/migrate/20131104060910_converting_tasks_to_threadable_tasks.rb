class ConvertingTasksToThreadableTasks < ActiveRecord::Migration
  def change
    Threadable::Conversation.where(type: 'Task').update_all(type: "Threadable::Task")
  end
end
