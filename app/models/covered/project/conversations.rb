class Covered::Project::Conversations < Covered::Conversations

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  def build attributes={}
    conversation_for scope.build(attributes)
  end
  alias_method :new, :build

  def create attributes={}
    super attributes.merge(project: project)
  end

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.conversations
  end

end
