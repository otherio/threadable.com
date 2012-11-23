class Test::Api::Tasks

  def self.create attributes
    @tasks ||= []
    attributes[:id] = @tasks.length
    task = Task.new(attributes)
    @tasks << task
    task
  end

  def self.find project_name, name
    @tasks.find{|task|
      task.project_name == project_name && task.name == name
    }
  end

end
