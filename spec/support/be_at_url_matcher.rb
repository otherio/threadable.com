# Usage: expect(page).to be_at_url sign_in_url(r: root_url)
RSpec::Matchers.define :be_at_url do |url|

  match_for_should do
    wait_until{ actual.current_url == url }
  end

  match_for_should_not do
    wait_until{ actual.current_url != url }
  end

  description do
    %(to be at url: #{url.inspect})
  end

  failure_message_for_should do |text|
    "expected to be at url: #{url.inspect} but was at: #{actual.current_url.inspect}"
  end

  failure_message_for_should_not do |text|
    "expected not to be at url: #{url}"
  end

end
