class Project::Tasks

  def get
    @tasks
  end

  def create attributes
    @tasks ||= []
    attributes[:id] = @tasks.length
    @tasks << Task.new(attributes)
  end

  def find name
    @tasks.find{|task| task.name == name }
  end

end
