class Covered::CurrentUser::Projects::Create < MethodObject

  def call current_user, attributes
    ::Project.transaction do
      project = current_user.covered.projects.create(attributes)
      project = Covered::CurrentUser::Project.new(current_user, project.project_record)
      project.members.add current_user if project.persisted?
      project
    end
  end

end
