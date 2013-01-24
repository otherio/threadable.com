require 'cucumber/rails'
require 'capybara_environment'

CapybaraEnvironment.setup!
World(CapybaraEnvironment)
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
