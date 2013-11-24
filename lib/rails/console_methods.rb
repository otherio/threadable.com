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
    options[:current_user_id] ||= User.with_email_address('alice@ucsd.covered.io').first.try(:id)
    options[:host] ||= URI.parse(app.root_url).host
    options[:port] ||= URI.parse(app.root_url).port
    @covered = Covered.new(options)
  end

  delegate :current_user, to: :covered

  def load_fixtures!
    ActiveRecord::FixtureBuilder.load_fixtures!
  end

  def reload_fixtures!
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
    load_fixtures!
  end

  def build_fixtures!
    ActiveRecord::FixtureBuilder.build_fixtures!
  end

  def rebuild_fixtures!
    ActiveRecord::FixtureBuilder.fixtures.map(&:path).each(&:delete)
    build_fixtures!
    ActiveRecord::FixtureBuilder.write_fixtures!
  end

  def log_sql!
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

end
