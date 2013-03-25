require 'selenium-webdriver'
require 'selenium/webdriver/common/error'

Then /^the first message should( not)? be shareworthy$/ do |knot|
  raise "this requires selenium" unless Capybara.current_driver == :selenium
  begin
    all('.message').first.native['shareworthy'].should == (knot ? nil : "true")
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    retry
  end
end
