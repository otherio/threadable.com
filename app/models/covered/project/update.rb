class Covered::Project::Update < MethodObject

  def call project, attributes
    !!project.project_record.update_attributes(attributes)
  end

end
