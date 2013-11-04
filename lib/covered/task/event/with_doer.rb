module Covered::Task::Event::WithDoer

  def doer_id
    content[:doer_id]
  end

  def doer_id= doer_id
    content[:doer_id] = doer_id
  end

  def doer
    @doer ||= Covered::User.find(doer_id)
  end

  def doer= doer
    @doer = doer
    self.doer_id = doer.id
  end

end
