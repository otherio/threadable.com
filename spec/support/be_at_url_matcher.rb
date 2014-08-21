# Usage: expect(page).to be_at_url sign_in_url(r: root_url)
RSpec::Matchers.define :be_at_url do |url|

  match do
    wait_until{ actual.current_url == url }
  end

  match_when_negated do
    wait_until{ actual.current_url != url }
  end

  description do
    %(to be at url: #{url.inspect})
  end

  failure_message do |text|
    "expected to be at url: #{url.inspect} but was at: #{actual.current_url.inspect}"
  end

  failure_message_when_negated do |text|
    "expected not to be at url: #{url}"
  end

end
