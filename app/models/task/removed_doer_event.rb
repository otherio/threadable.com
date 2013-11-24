class Task::RemovedDoerEvent < Task.const_get(:Event, false)

  include Task::Event::WithDoer

end
