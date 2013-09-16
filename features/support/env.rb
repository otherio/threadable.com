ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../../lib/fix_minitest", __FILE__)
require 'cucumber/rails'

# cucumber requires DatabaseCleaner - fuckyou
class << Cucumber::Rails::Database
  def before_js; end
  def before_non_js; end
end

require 'capybara_environment'

World(CapybaraEnvironment)

Cucumber::Rails::World.use_transactional_fixtures = false
CapybaraEnvironment.before_suite!

Before do
  reload_fixtures!
end

Around('@email') do |scenario, block|
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries.clear
  block.call
end
