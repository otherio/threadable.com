class Covered::Mailer < ActionMailer::Base

  class << self
    public :new
  end

  def initialize(covered)
    super()
    @covered = covered
    self.default_url_options = {host: covered.host, port: covered.port, protocol: covered.protocol}
  end
  attr_reader :covered

  def generate method_name, *args
    process(method_name, *args)
    message
  end

  # restore the default method_missing method
  define_singleton_method :method_missing, BasicObject.method(:method_missing)

end
