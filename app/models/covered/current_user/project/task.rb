class Covered::CurrentUser::Project::Task < Covered::CurrentUser::Project::Conversation

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

  def done! now=Time.now
    return false if done?
    task_record.transaction do
      task_record.update! done_at: now
      task_record.events.create! type: 'Task::DoneEvent', user_id: covered.current_user.id
    end
    true
  end

  def undone!
    return false unless done?
    task_record.transaction do
      task_record.update! done_at: nil
      task_record.events.create! type: 'Task::UndoneEvent', user_id: covered.current_user.id
    end
    true
  end

end
