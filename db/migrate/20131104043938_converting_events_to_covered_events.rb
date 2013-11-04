class ConvertingEventsToCoveredEvents < ActiveRecord::Migration
  def change
    Covered::Event.transaction do
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
        Covered::Event.where(type: type).update_all(type: "Covered::#{type}")
      }
    end
  end
end
