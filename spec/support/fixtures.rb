module RSpec::Support::Fixtures

  def self.fixtures_built?
    !!@built
  end

  def self.fixtures_built!
    @built = true
  end

  def self.fixtures_loaded?
    !!@loaded
  end

  def self.fixtures_loaded!
    @loaded = true
  end

  def self.fixtures_not_loaded!
    @loaded = false
  end

  delegate :fixtures_built?, :fixtures_built!, :fixtures_loaded?, :fixtures_loaded!, :fixtures_not_loaded!, to: self

  def path
    ActiveRecord::FixtureBuilder.config.path
  end

  def truncate_all_tables!
    ActiveRecord::Base.connection_handler.clear_all_connections! unless test_transaction_open?
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
    fixtures_not_loaded! unless test_transaction_open?
  end

  def build_fixtures!
    return false if fixtures_built? # only build fixtures once
    truncate_all_tables!
    ActiveRecord::FixtureBuilder.build_fixtures!
    ActiveRecord::FixtureBuilder.write_fixtures!
    fixtures_built!
    fixtures_loaded! unless test_transaction_open?
    true
  end

  def load_fixtures!
    return if fixtures_loaded?
    build_fixtures! and return
    truncate_all_tables!
    ActiveRecord::FixtureBuilder.load_fixtures!
    fixtures_loaded!
  end

end
