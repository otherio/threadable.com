require_dependency 'covered/task'

class Covered::Task::AddedDoerEvent < Covered::Task::Event

  include Covered::Task::DoerEvent

end
