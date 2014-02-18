class Threadable::Task < Threadable::Conversation

  alias_method :task_record, :conversation_record

  delegate *%w{
    done_at
    done?
    position
  }, to: :task_record

  let(:doers){ Doers.new(self) }

  def being_done_by? user
    doers.include? user
  end

  def done! now=Time.now
    return false if done?
    Threadable.transaction do
      task_record.update! done_at: now
      events.create! :task_done
    end
    true
  end

  def undone!
    return false unless done?
    Threadable.transaction do
      task_record.update! done_at: nil
      events.create! :task_undone
    end
    true
  end

  undef_method :convert_to_task!

  def convert_to_conversation!
    Threadable::Task.new threadable, conversation_record.convert_to_conversation!
  end

  def scope
    ::Task.order('conversations.position DESC')
  end

end
