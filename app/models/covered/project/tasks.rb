class Covered::Project::Tasks < Covered::Tasks

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
  end

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
    project.project_record.tasks
  end

end
