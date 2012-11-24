class Project::Tasks < Struct.new(:project)

  def create attributes
    @tasks ||= []
    attributes[:id] = @tasks.length
    @tasks << Task.new(attributes)
  end

  def find name
    @tasks ||= []
    @tasks.find{|task| task.name == name }
  end

  def new attributes
    Task.new(attributes.merge(project: project))
  end

end
