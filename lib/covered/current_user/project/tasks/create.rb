require 'covered/current_user/project/conversations/create'

class Covered::CurrentUser::Project::Tasks::Create < MethodObject

  def call project, options
    Covered::CurrentUser::Project::Conversations::Create.call(project, options.merge(task:true))
  end

end
