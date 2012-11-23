module Test::Api::Emails

  def self.send attributes
    @emails ||= []
    @emails << Email.new(attributes)
  end

  def self.reset!
    @emails = []
  end

  class << self
    attr_reader :emails
  end

  class Email
    include Virtus
    attribute :to, String
    attribute :body, String
  end


end
