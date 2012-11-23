class Test::Api::Project

  include Virtus

  attribute :name, String

  def self.create attributes
    @projects ||= []
    project = new(attributes)
    @projects << project
    project
  end

  def self.find name
    @projects.find{|project| project.name == name }
  end

  def tasks
    @tasks ||= Tasks.new
  end

  class Tasks

    def get
      @tasks
    end

    def create attributes
      @tasks ||= []
      @tasks << Test::Api::Task.new(attributes)
    end

    def self.find name
      @tasks.find{|task| task.name == name }
    end

  end

end
