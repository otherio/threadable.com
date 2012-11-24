module Test::Api

  def self.reset!
    Test::Api::Projects.reset!
    Test::Api::Tasks.reset!
    Test::Api::Users.reset!
    Api::Emails.reset!
  end

end
