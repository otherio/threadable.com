$:.unshift File.expand_path('../../../lib', __FILE__)
require 'capybara/cucumber'
require 'patches/capybara'
require 'debugger'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.ignore_hidden_elements = true
Capybara.default_driver         = :selenium
Capybara.javascript_driver      = :selenium
Capybara.default_selector       = :css
Capybara.default_wait_time      = 5
Capybara.app_host               = 'http://localhost:3000'

# World(Test::Paths)

# Before do
#   # Rails.application.routes.default_url_options[:host] = 'example.com'
#   Multify.reset!
# end
