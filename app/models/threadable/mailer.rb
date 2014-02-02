class Threadable::Mailer < ActionMailer::Base

  class << self
    public :new
  end

  def initialize(threadable)
    super()
    @threadable = threadable
    self.default_url_options = {host: threadable.host, port: threadable.port, protocol: threadable.protocol}
  end
  attr_reader :threadable

  def generate method_name, *args
    process(method_name, *args)
    message
  end

  # restore the default method_missing method
  define_singleton_method :method_missing, BasicObject.method(:method_missing)

end
