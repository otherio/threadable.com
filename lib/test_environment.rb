require 'factory_girl'
require 'database_cleaner'

module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    extension = "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
    include extension unless extension.is_a? Class
  end

  def fixture_path
    "#{::Rails.root}/lib/test_environment/fixtures"
  end

  def database_cleaner_strategy
    :transaction
  end

  def before_suite!
    ::DatabaseCleaner.clean_with :truncation
    ::TestEnvironment::Fixtures.load!
  end

  extend self

end

