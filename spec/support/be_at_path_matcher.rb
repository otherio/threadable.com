# Usage: expect(page).to be_at_path '/'
RSpec::Matchers.define :be_at_path do |path|

  match_for_should do
    wait_until{ actual.current_path == path }
  end

  match_for_should_not do
    wait_until{ actual.current_path != path }
  end

  description do
    %(to be at path: #{path.inspect})
  end

  failure_message_for_should do |text|
    "expected to be at path: #{path.inspect} but was at: #{actual.current_path.inspect}"
  end

  failure_message_for_should_not do |text|
    "expected not to be at path: #{path}"
  end

end
