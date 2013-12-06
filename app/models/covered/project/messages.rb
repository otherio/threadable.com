class Covered::Project::Messages < Covered::Messages

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  def find_by_child_message_header header
    message_for (FindByChildHeader.call(project.id, header) or return)
  end

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.messages
  end

end
