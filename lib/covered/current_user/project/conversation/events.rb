class Covered::CurrentUser::Project::Conversation::Events

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
    when "Conversation::Event";        Covered::CurrentUser::Project::Conversation::Event
    when "Conversation::CreatedEvent"; Covered::CurrentUser::Project::Conversation::CreatedEvent
    when "Task::Event";                Covered::CurrentUser::Project::Task::Event
    when "Task::CreatedEvent";         Covered::CurrentUser::Project::Task::CreatedEvent
    when "Task::DoneEvent";            Covered::CurrentUser::Project::Task::DoneEvent
    when "Task::UndoneEvent";          Covered::CurrentUser::Project::Task::UndoneEvent
    when "Task::AddedDoerEvent";       Covered::CurrentUser::Project::Task::AddedDoerEvent
    when "Task::RemovedDoerEvent";     Covered::CurrentUser::Project::Task::RemovedDoerEvent
    end
    _class.new(conversation, event_record)
  end

end

require 'covered/current_user/project/conversation/event'
require 'covered/current_user/project/conversation/created_event'
require 'covered/current_user/project/task/event'
require 'covered/current_user/project/task/created_event'
require 'covered/current_user/project/task/done_event'
require 'covered/current_user/project/task/undone_event'
require 'covered/current_user/project/task/added_doer_event'
require 'covered/current_user/project/task/removed_doer_event'
