module Test::Api

  def self.reset!
    Test::Api::Project.instance_variable_set(:@projects, nil)
    # Test::Api::Project.instance_variable_set(:@tasks, nil)
  end

end
