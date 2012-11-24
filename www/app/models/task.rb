class Task

  include Model

  attribute :id, Integer
  attribute :name, String
  attribute :slug, String
  attribute :project_id, Integer

  def to_param
    slug
  end

  def project
    @project ||= Api::Projects.find_by_id(project_id)
  end

  def project= project
    @project = project
    self.project_id = project.id
  end

  def doers
    @doers ||= Doers.new(self)
  end

  def followers
    @followers ||= Followers.new(self)
  end

end
