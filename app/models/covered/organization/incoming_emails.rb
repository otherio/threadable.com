require_dependency 'covered/project'

class Covered::Organization::IncomingEmails < Covered::IncomingEmails

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  private

  def scope
    project.project_record.incoming_emails
  end

end
