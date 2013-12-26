require_dependency 'task/event/with_doer'

class Task::AddedDoerEvent < Task::Event

  include Task::Event::WithDoer

end
