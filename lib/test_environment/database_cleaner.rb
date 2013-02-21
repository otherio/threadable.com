# for some reason specs in shared example groups run their
# before blocks twice. I think this is a bug.
module TestEnvironment::DatabaseCleaner

  def database_cleaner_start!
    unless @database_cleaner_started
      DatabaseCleaner.strategy = database_cleaner_strategy
      DatabaseCleaner.start
      @database_cleaner_started = true
    end
  end

  def database_cleaner_clean!
    if @database_cleaner_started
      DatabaseCleaner.clean
      @database_cleaner_started = false
      if database_cleaner_strategy == :truncation
        TestEnvironment::Fixtures.load!
      end
    end
  end

end
