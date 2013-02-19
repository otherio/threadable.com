class Task::Event < Conversation::Event

  attr_accessible :task

  def task_id
    conversation_id
  end

  def task_id= task_id
    self.conversation_id = task_id
  end

  def task
    conversation
  end

  def task= task
    self.conversation = task
  end

end
