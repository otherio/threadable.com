require 'covered/current_user/project/task/doer_event'

class Covered::CurrentUser::Project::Task::RemovedDoerEvent < Covered::CurrentUser::Project::Task::Event

  include Covered::CurrentUser::Project::Task::DoerEvent

end
