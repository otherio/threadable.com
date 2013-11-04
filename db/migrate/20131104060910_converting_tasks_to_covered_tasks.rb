class ConvertingTasksToCoveredTasks < ActiveRecord::Migration
  def change
    Covered::Conversation.where(type: 'Task').update_all(type: "Covered::Task")
  end
end
