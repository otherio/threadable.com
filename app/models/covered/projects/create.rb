class Covered::Projects::Create < MethodObject

  def call projects, attributes
    project = Covered::Project.new(projects.covered, ::Project.create(attributes))
    if projects.covered.current_user
      project.members.add(user: projects.covered.current_user, send_join_notice: false)
    end
    project
  end

end
