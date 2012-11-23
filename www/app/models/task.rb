class Task

  include Virtus

  attribute :id, Integer
  attribute :name, String
  attribute :project_name, String

  def to_param
    id
  end

  def project
    @project_name ||= Api::Projects.find(project_name)
  end

  def doers
    @doers ||= Doers.new(self)
  end

  def followers
    @followers ||= Followers.new(self)
  end




end
