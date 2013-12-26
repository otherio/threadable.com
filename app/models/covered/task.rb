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
      @covered.events.create!(
        type: 'Task::DoneEvent',
        user_id: covered.current_user_id,
        conversation_id: task_record.id
      )
    end
    true
  end

  def undone!
    return false unless done?
    Covered.transaction do
      task_record.update! done_at: nil
      @covered.events.create!(
        type: 'Task::UndoneEvent',
        user_id: covered.current_user_id,
        conversation_id: task_record.id
      )
    end
    true
  end

end
