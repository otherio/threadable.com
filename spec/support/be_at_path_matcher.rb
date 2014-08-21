# Usage: expect(page).to be_at_path '/'
RSpec::Matchers.define :be_at_path do |path|

  match do
    wait_until{ actual.current_path == path }
  end

  match_when_negated do
    wait_until{ actual.current_path != path }
  end

  description do
    %(to be at path: #{path.inspect})
  end

  failure_message do |text|
    "expected to be at path: #{path.inspect} but was at: #{actual.current_path.inspect}"
  end

  failure_message_when_negated do |text|
    "expected not to be at path: #{path}"
  end

end
