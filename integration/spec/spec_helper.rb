# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'capybara/rspec'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'multify'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.expand_path('..',__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include ServersSupport
  config.before :all do
    Multify::Servers.start!
  end

end
