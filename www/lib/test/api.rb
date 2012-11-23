module Test::Api

  def self.reset!
    Test::Api::Project.instance_variable_set(:@projects, nil)
    Api::Emails.reset!
  end

end
