SELENIUM = ENV['SELENIUM'] == 'true'
# SELENIUM_BROWSER=safari
# SELENIUM_BROWSER=chrome
# SELENIUM_BROWSER=firefox
SELENIUM_BROWSER = (ENV['SELENIUM_BROWSER'].presence || :chrome).to_sym

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: SELENIUM_BROWSER)
end

Capybara.exact_options          = true
Capybara.ignore_hidden_elements = true
Capybara.default_driver         = SELENIUM ? :selenium : :webkit
Capybara.javascript_driver      = SELENIUM ? :selenium : :webkit
Capybara.default_selector       = :css
Capybara.default_wait_time      = 5
Capybara.server_host            = '127.0.0.1'
Capybara.server_port            = begin
  server = TCPServer.new(Capybara.server_host, 0)
  server.addr[1]
ensure
  server.close if server
end