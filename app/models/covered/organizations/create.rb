class Covered::Organizations::Create < MethodObject

  def call projects, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    project_record = ::Organization.create(attributes)
    project = Covered::Organization.new(projects.covered, project_record)
    return project unless project_record.persisted?

    if projects.covered.current_user && add_current_user_as_a_member
      project.members.add(user: projects.covered.current_user, send_join_notice: false)
    end
    return project
  end

end
