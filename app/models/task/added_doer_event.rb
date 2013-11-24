class Task::AddedDoerEvent < Task::Event

  include Task::Event::WithDoer

end
