class Covered::Project::Conversation::Events

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def all
    scope.map{ |event| event_for event }
  end

  def newest
    event_for (scope.last or return)
  end

  def oldest
    event_for (scope.first or return)
  end

  def count
    scope.count
  end



  def build attributes={}
    event_for scope.build(attributes)
  end
  alias_method :new, :build

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    conversation.conversation_record.events
  end

  def event_for event_record
    _class = case event_record.type
    when "Conversation::Event";        Covered::Project::Conversation::Event
    when "Conversation::CreatedEvent"; Covered::Project::Conversation::CreatedEvent
    when "Task::Event";                Covered::Project::Task::Event
    when "Task::CreatedEvent";         Covered::Project::Task::CreatedEvent
    when "Task::DoneEvent";            Covered::Project::Task::DoneEvent
    when "Task::UndoneEvent";          Covered::Project::Task::UndoneEvent
    when "Task::AddedDoerEvent";       Covered::Project::Task::AddedDoerEvent
    when "Task::RemovedDoerEvent";     Covered::Project::Task::RemovedDoerEvent
    end
    _class.new(conversation, event_record)
  end

end
