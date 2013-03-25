Then /^the first message should( not)? be knowledge$/ do |knot|
  begin
    all('.message').first.native['knowledge'].should == (knot ? nil : "true")
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    retry
  end
end
