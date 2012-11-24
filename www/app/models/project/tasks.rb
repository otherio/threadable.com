class Project::Tasks

  def initialize project
    @project = project
  end

  def create! attributes
    Task.create!(attributes.merge(project: @project))
  end

  def all
    Task.all(@project.id)
  end

  def find_by_id id
    Task.find_by_id(@project.id, id)
  end

  def find_by_name name
    Task.find_by_name(@project.id, name)
  end

  def find_by_slug slug
    Task.find_by_slug(@project.id, slug)
  end

  def new attributes={}
    Task.new(attributes.merge(project: @project))
  end

end
