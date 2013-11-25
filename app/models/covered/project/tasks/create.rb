class Covered::Project::Tasks::Create < MethodObject

  def call project, options
    Covered::Project::Conversations::Create.call(project, options.merge(task:true))
  end

end
