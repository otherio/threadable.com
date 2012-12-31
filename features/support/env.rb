require 'cucumber/rails'
require 'patches/capybara'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.ignore_hidden_elements = true
Capybara.default_driver         = :selenium
Capybara.javascript_driver      = :selenium
Capybara.default_selector       = :css
Capybara.default_wait_time      = 5
