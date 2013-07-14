Then /^the first message should( not)? be shareworthy$/ do |knot|
  begin
    page.document.synchronize do
      selector = knot ? '.message:not([shareworthy])' : '.message[shareworthy]'
      raise Capybara::ElementNotFound unless first(selector) == first('.message')
    end
  rescue Capybara::ElementNotFound
    raise "the first message does is #{'not ' if knot} shareworthy"
  end
end
