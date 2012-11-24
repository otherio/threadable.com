class Task

  include Model

  def self.find_by_id *args
    new Api::Tasks.find_by_id(*args)
  end

  def self.find_by_name *args
    new Api::Tasks.find_by_name(*args)
  end

  def self.find_by_slug *args
    new Api::Tasks.find_by_slug(*args)
  end

  attribute :id, Integer
  attribute :name, String
  attribute :slug, String
  attribute :project_id, Integer

  def to_param
    slug
  end

  def project
    @project ||= Project.find_by_id(project_id)
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
