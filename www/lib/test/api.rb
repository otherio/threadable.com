module Test::Api

  def self.reset!
    Test::Api::Projects.reset!
    Api::Emails.reset!
  end

end
