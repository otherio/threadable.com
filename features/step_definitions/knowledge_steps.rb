Then /^the first message should( not)? be knowledge$/ do |knot|
  begin
    page.document.synchronize do
      selector = knot ? '.message:not([knowledge])' : '.message[knowledge]'
      raise Capybara::ElementNotFound unless first(selector) == first('.message')
    end
  rescue Capybara::ElementNotFound
    raise "the first message does is #{'not ' if knot} knowledgable"
  end
end
