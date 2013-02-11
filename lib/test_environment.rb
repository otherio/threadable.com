require 'factory_girl'
require 'database_cleaner'

module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    include "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
  end

  def before_all! test=nil
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  def before_each! test=nil

  end

  def after_each! test=nil

  end

  extend self

end

