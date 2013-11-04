Then /^the first message should( not)? be knowledge$/ do |knot|
  begin
    selector = knot ? '.message:not([knowledge])' : '.message[knowledge]'
    page.document.synchronize do
      raise Capybara::ElementNotFound unless first(selector) == first('.message')
    end
  rescue Capybara::ElementNotFound
    raise "the first message is #{'not ' unless knot}knowledgable"
  end
end
