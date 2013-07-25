module TestEnvironment::Fixtures

  def fixtures_path
    ActiveRecord::FixtureBuilder.config.fixtures_path
  end

  def reload_fixtures!
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
    ActiveRecord::FixtureBuilder.load_fixtures!
  end

end
