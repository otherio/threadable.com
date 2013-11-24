class MovingModelsBackToAppModels < ActiveRecord::Migration
  def up
    Event.transaction do
      %w{
        Conversation::Event
        Conversation::CreatedEvent
        Task::Event
        Task::CreatedEvent
        Task::DoneEvent
        Task::UndoneEvent
        Task::AddedDoerEvent
        Task::RemovedDoerEvent
      }.each{|type|
        Event.where(type: "Covered::#{type}").update_all(type: "#{type}")
      }
    end

    Conversation.where(type: 'Covered::Task').update_all(type: "Task")
  end

  def down
    Event.transaction do
      %w{
        Conversation::Event
        Conversation::CreatedEvent
        Task::Event
        Task::CreatedEvent
        Task::DoneEvent
        Task::UndoneEvent
        Task::AddedDoerEvent
        Task::RemovedDoerEvent
      }.each{|type|
        Event.where(type: "#{type}").update_all(type: "Covered::#{type}")
      }
    end

    Conversation.where(type: 'Task').update_all(type: "Covered::Task")
  end
end
