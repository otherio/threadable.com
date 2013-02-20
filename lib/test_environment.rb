require 'factory_girl'
require 'database_cleaner'

module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    extension = "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
    include extension unless extension.is_a? Class
  end

  def before_all! test=nil
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    TestEnvironment::Fixtures.load!
  end

  def before_each! test=nil

  end

  def after_each! test=nil

  end

  extend self

end

