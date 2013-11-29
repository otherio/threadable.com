class Covered::Projects::Create < MethodObject

  def call projects, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    project = Covered::Project.new(projects.covered, ::Project.create(attributes))
    if projects.covered.current_user && add_current_user_as_a_member
      project.members.add(user: projects.covered.current_user, send_join_notice: false)
    end
    project
  end

end
