require 'factory_girl'
require 'database_cleaner'

module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    extension = "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
    include extension unless extension.is_a? Class
  end

  def database_cleaner_strategy
    :transaction
  end

  def before_suite! test=nil
    DatabaseCleaner.clean_with :truncation
    debugger;1
    TestEnvironment::Fixtures.load!
  end

  def before_each! test=nil
    DatabaseCleaner.strategy = database_cleaner_strategy
    @database_cleaner_started or begin
      DatabaseCleaner.start
      @database_cleaner_started = true
    end
  end

  def after_each! test=nil
    DatabaseCleaner.clean
    @database_cleaner_started = false
  end

  extend self

end

