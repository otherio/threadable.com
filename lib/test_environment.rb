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

  def before_suite!
    ::TestEnvironment::Fixtures.configure_fixture_builder!
  end

  extend self

end

