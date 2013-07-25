if defined? ActiveRecord::FixtureBuilder
  ActiveRecord::FixtureBuilder.configure do |c|
    c.fixtures_path = Rails.root + 'lib/test_environment/fixtures'
    c.builders_path = Rails.root + 'lib/test_environment/fixtures/builders'
  end
end
