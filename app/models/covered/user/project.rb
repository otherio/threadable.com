class Covered::User::Project < Covered::Project

  def initialize projects, project_record
    @covered = projects.covered
    @projects = projects
    @project_record = project_record
  end
  attr_reader :projects

  def leave!
    members.remove(user: projects.user)
  end

end
