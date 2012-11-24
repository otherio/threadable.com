class Task

  include Model

  def self.all project_id
    Api::Tasks.all(project_id).map{|t| new(t) }
  end

  def self.find_by_id *args
    attributes = Api::Tasks.find_by_id(*args)
    attributes.nil? ? nil : new(attributes)
  end

  def self.find_by_name *args
    attributes = Api::Tasks.find_by_name(*args)
    attributes.nil? ? nil : new(attributes)
  end

  def self.find_by_slug *args
    attributes = Api::Tasks.find_by_slug(*args)
    attributes.nil? ? nil : new(attributes)
  end

  attribute :id, Integer
  attribute :name, String
  attribute :slug, String
  attribute :project_id, Integer
  attribute :done, Boolean
  attribute :due_date, Date

  validates :name, :project_id, :presence => true

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
