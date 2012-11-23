module Test::Api::Projects

  def self.reset!
    @project = []
  end

  def self.create attributes
    @projects ||= []
    project = Project.new(attributes)
    @projects << project
    project
  end

  def self.find name
    @projects.find{|project| project.name == name }
  end

end
