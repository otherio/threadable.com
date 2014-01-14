require 'rails/console/app'

module Rails::ConsoleMethods

  def self.included base
    super
  end

  def covered options=nil
    @covered = nil if @covered && @covered.class != Covered::Class
    return @covered if options.nil? && @covered
    @covered = nil
    options ||= {}
    options[:current_user_id] ||= User.with_email_address('alice@ucsd.example.com').first.try(:id)
    options[:host] ||= URI.parse(app.root_url).host
    options[:port] ||= URI.parse(app.root_url).port
    @covered = Covered.new(options)
  end

  def alice
    @alice ||= covered.users.find_by_email_address!('alice@ucsd.example.com')
  end

  delegate :current_user, to: :covered

  def build_fixtures!
    Fixtures.build!
  ensure
    Timecop.return
  end

  def log_sql!
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

end
