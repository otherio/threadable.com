class Covered::Mailer < ActionMailer::Base

  class << self
    public :new
  end

  include Covered::Dependant::AccessorMethods

  def initialize(covered)
    super()
    self.covered = covered
    self.default_url_options = {host: covered.host, port: covered.port, protocol: covered.protocol}
  end

  def generate method_name, *args
    process(method_name, *args)
    message
  end

  # restore the default method_missing method
  define_singleton_method :method_missing, BasicObject.method(:method_missing)

end
