
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end


Capybara.ignore_hidden_elements = true
Capybara.default_driver         = :rack_test
Capybara.javascript_driver      = :selenium
Capybara.default_selector       = :css
Capybara.default_wait_time      = 5
# Capybara.app_host               = "http://www.local-change.org"

module CapybaraEnvironment


end
