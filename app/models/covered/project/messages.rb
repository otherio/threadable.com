class Covered::Project::Messages < Covered::Messages

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.messages
  end

end
