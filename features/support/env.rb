ENV["RAILS_ENV"] ||= 'test'
require 'cucumber/rails'
require 'capybara_environment'

World(CapybaraEnvironment)

Cucumber::Rails::World.fixture_path = TestEnvironment.fixture_path
Cucumber::Rails::World.use_transactional_fixtures = false
Cucumber::Rails::Database.javascript_strategy = :truncation

CapybaraEnvironment.before_suite!

