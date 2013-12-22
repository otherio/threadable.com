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

  def stub_mixpanel!
    stub_request(:any, 'https://api.mixpanel.com/track').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/people').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/engage').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/import').to_return({ :body => '{"status": 1, "error": null}' })
  end

  def empty_databases!
    ActiveRecord::Base.connection_handler.clear_all_connections! unless test_transaction_open?
    ::Fixtures.empty_databases!
    fixtures_not_loaded! unless test_transaction_open?
  end

  def build_fixtures!
    return false if fixtures_built? # only build fixtures once
    stub_mixpanel!
    empty_databases!
    ::Fixtures.build!
    fixtures_built!
    fixtures_loaded! unless test_transaction_open?
    true
  end

  def load_fixtures!
    return if fixtures_loaded?
    build_fixtures! and return
    empty_databases!
    ::Fixtures.load!
    fixtures_loaded!
  end

end
