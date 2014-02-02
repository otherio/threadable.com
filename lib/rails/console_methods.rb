require 'rails/console/app'

module Rails::ConsoleMethods

  def self.included base
    super
  end

  def threadable options=nil
    @threadable = nil if @threadable && @threadable.class != Threadable::Class
    return @threadable if options.nil? && @threadable
    @threadable = nil
    options ||= {}
    options[:current_user_id] ||= User.with_email_address('alice@ucsd.example.com').first.try(:id)
    options[:host] ||= URI.parse(app.root_url).host
    options[:port] ||= URI.parse(app.root_url).port
    @threadable = Threadable.new(options)
  end

  def alice
    @alice ||= threadable.users.find_by_email_address!('alice@ucsd.example.com')
  end

  def amy
    @amy ||= threadable.users.find_by_email_address!('amywong.phd@gmail.com')
  end

  def sign_in_as email_address
    threadable.current_user = threadable.users.find_by_email_address(email_address)
  end

  delegate :current_user, to: :threadable

  def build_fixtures!
    Fixtures.build!
  ensure
    Timecop.return
  end

  def log_sql!
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

end
