require 'factory_girl'
module TestEnvironment

  include FactoryGirl::Syntax::Methods

  Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |path|
    include "TestEnvironment::#{File.basename(path, '.rb').camelize}".constantize
  end

end
