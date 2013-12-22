require_dependency 'covered/user'

class Covered::User::Organization < Covered::Organization

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
