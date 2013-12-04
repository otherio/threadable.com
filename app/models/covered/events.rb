class Covered::Events < Covered::Collection

  def all
    scope.reload.map{ |event| event_for event }
  end


  def newest
    event_for (scope.last or return)
  end

  def oldest
    event_for (scope.first or return)
  end


  def build attributes={}
    event_for scope.build(attributes)
  end
  alias_method :new, :build


  private

  def scope
    ::Event.all
  end

  def event_for event_record
    case event_record.type
    when "Conversation::CreatedEvent"; Covered::Conversation::CreatedEvent
    when "Task::CreatedEvent";         Covered::Task::CreatedEvent
    when "Task::DoneEvent";            Covered::Task::DoneEvent
    when "Task::UndoneEvent";          Covered::Task::UndoneEvent
    when "Task::AddedDoerEvent";       Covered::Task::AddedDoerEvent
    when "Task::RemovedDoerEvent";     Covered::Task::RemovedDoerEvent
    else; raise "unknown even type #{event_record.type.inspect}"
    end.new(covered, event_record)
  end

end
