class Task::Event < Conversation::Event

  belongs_to :task, foreign_key: 'conversation_id'

end
