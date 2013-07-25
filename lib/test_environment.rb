require 'factory_girl'

module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    extension = "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
    include extension unless extension.is_a? Class
  end

  def use_test_transaction?
    true
  end

  def before_suite!
    # this keeps minitest from running at_exit like a dick
    test_storage = Rails.root.join('public/storage/test')
    test_storage.rmtree if test_storage.exist?
    ActiveRecord::FixtureBuilder.build_fixtures!
    ActiveRecord::FixtureBuilder.write_fixtures!
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  extend self

end

