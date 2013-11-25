class Covered::Project::Task < Covered::Project::Conversation

  autoload :Event
  autoload :CreatedEvent
  autoload :DoneEvent
  autoload :UndoneEvent
  autoload :AddedDoerEvent
  autoload :RemovedDoerEvent
  autoload :Doers

  def initialize project, conversation_record
    super
    @task_record = @conversation_record
  end
  attr_reader :task_record

  delegate *%w{
    done?
    position
  }, to: :task_record

  let(:doers){ Doers.new(self) }

end
