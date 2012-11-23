class Project

  include Virtus

  attribute :id, Integer
  attribute :name, String

  def to_param
    id
  end

  def tasks
    @tasks ||= Project::Tasks.new
  end

end
