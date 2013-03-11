class Task::AddedDoerEvent < Task::Event

  def doer
    @doer ||= User.find(content[:doer_id])
  end

end
