require 'covered/current_user/project/task/doer_event'

class Covered::CurrentUser::Project::Task::AddedDoerEvent < Covered::CurrentUser::Project::Task::Event

  include Covered::CurrentUser::Project::Task::DoerEvent

end
