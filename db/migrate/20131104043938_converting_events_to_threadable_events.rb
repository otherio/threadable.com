class ConvertingEventsToThreadableEvents < ActiveRecord::Migration
  def change
    Threadable::Event.transaction do
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
        Threadable::Event.where(type: type).update_all(type: "Threadable::#{type}")
      }
    end
  end
end
