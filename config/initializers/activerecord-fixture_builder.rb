if defined? ActiveRecord::FixtureBuilder
  ActiveRecord::FixtureBuilder.configure do |c|
    c.fixtures_path = Rails.root + 'tmp/fixtures'
    c.builders_path = Rails.root + 'lib/fixture_builders'

  end
  ActiveRecord::FixtureBuilder.config.fixtures_path.mkdir unless
    ActiveRecord::FixtureBuilder.config.fixtures_path.exist?
end
