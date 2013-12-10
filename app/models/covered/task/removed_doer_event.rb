require_dependency 'covered/task'

class Covered::Task::RemovedDoerEvent < Covered::Task::Event

  include Covered::Task::DoerEvent

end
