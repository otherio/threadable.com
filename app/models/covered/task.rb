class Covered::Task < Covered::Conversation

  autoload :Event
  autoload :CreatedEvent
  autoload :DoneEvent
  autoload :UndoneEvent
  autoload :AddedDoerEvent
  autoload :RemovedDoerEvent
  autoload :Doers

  alias_method :task_record, :conversation_record

  delegate *%w{
    done?
    position
  }, to: :task_record

  let(:doers){ Doers.new(self) }

  def done! now=Time.now
    return false if done?
    task_record.transaction do
      task_record.update! done_at: now
      task_record.events.create! type: 'Task::DoneEvent', user_id: covered.current_user_id
    end
    true
  end

  def undone!
    return false unless done?
    task_record.transaction do
      task_record.update! done_at: nil
      task_record.events.create! type: 'Task::UndoneEvent', user_id: covered.current_user_id
    end
    true
  end

end