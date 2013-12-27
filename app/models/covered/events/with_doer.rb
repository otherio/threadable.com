module Covered::Events::WithDoer

  def doer_id
    content[:doer_id]
  end

  def doer_id= doer_id
    content[:doer_id] = doer_id
  end

  def doer
    @doer ||= covered.users.find_by_id!(doer_id) if doer_id
  end

  def doer= doer
    @doer = doer
    self.doer_id = doer.id
  end

end

