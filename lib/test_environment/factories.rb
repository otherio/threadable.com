require 'factory_girl'
require 'ffaker'

Dir[File.expand_path('../factories/*.rb', __FILE__)].each do |factory|
  require factory
end

module TestEnvironment::Factories

end
