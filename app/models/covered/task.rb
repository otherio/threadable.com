class Covered::Task < Covered::Conversation

  alias_method :task_record, :conversation_record

  delegate *%w{
    done?
    position
  }, to: :task_record

  let(:doers){ Doers.new(self) }

  def done! now=Time.now
    return false if done?
    Covered.transaction do
      task_record.update! done_at: now
      task_record.events.create! type: 'Task::DoneEvent', user_id: covered.current_user_id
    end
    true
  end

  def undone!
    return false unless done?
    Covered.transaction do
      task_record.update! done_at: nil
      task_record.events.create! type: 'Task::UndoneEvent', user_id: covered.current_user_id
    end
    true
  end

end

require_dependency 'covered/task/event'
require_dependency 'covered/task/removed_doer_event'
require_dependency 'covered/task/undone_event'
require_dependency 'covered/task/added_doer_event'
require_dependency 'covered/task/created_event'
require_dependency 'covered/task/doer'
require_dependency 'covered/task/doer_event'
require_dependency 'covered/task/doers'
require_dependency 'covered/task/done_event'
