class Task::RemovedDoerEvent < Task::Event

  include Task::Event::WithDoer

end
