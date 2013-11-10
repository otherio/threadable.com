module TestEnvironment::Fixtures

  def fixtures_path
    ActiveRecord::FixtureBuilder.config.fixtures_path
  end

  def reload_fixtures!
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
    ActiveRecord::FixtureBuilder.load_fixtures!
  end

  def rebuild_fixtures!
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
    ActiveRecord::FixtureBuilder.build_fixtures!
    ActiveRecord::FixtureBuilder.write_fixtures!
  end
end
