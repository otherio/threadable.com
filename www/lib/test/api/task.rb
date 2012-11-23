class Test::Api::Task

  include Virtus

  attribute :name, String

  # def self.create attributes
  #   @tasks ||= []
  #   task = new(attributes)
  #   @tasks << task
  #   task
  # end

  # def self.find name
  #   @tasks.find{|task| task.name == name }
  # end

end
