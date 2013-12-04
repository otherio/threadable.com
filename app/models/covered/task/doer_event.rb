module Covered::Task::DoerEvent

  def doer_id
    event_record.content[:doer_id]
  end

  def doer
    @doer ||= Covered::Task::Doer.new(task, ::User.find(doer_id))
  end

  def as_json options=nil
    super.merge(doer_id: doer_id)
  end

  def inspect
    %(#<#{self.class} actor_id: #{actor_id.inspect}, doer_id: #{doer_id.inspect}, task_id: #{task.id.inspect}>)
  end

end
