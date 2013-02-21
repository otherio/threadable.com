require 'cucumber/rails'
require 'capybara_environment'

World(CapybaraEnvironment)
CapybaraEnvironment.before_suite!

Before do |scenario|
  before_each! scenario
end

After do |scenario|
  after_each! scenario
end
