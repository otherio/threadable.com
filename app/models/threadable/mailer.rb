class Threadable::Mailer < ActionMailer::Base

  class << self
    public :new
  end

  layout 'email'

  def initialize(threadable)
    super()
    @threadable = threadable
    self.default_url_options = {host: threadable.host, port: threadable.port, protocol: threadable.protocol}
  end
  attr_reader :threadable

  def generate method_name, *args
    Haml::Template.options[:format] = :html4
    process(method_name, *args)
    Haml::Template.options[:format] = :html5
    message
  end

  # restore the default method_missing method
  define_singleton_method :method_missing, BasicObject.method(:method_missing)

end
