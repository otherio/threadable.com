RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = @prefix ? :"#{@to}_#{method}" : method
    @delegator = delegator
    begin
      @delegator.send(@to)
    rescue NoMethodError
      raise "#{@delegator} does not respond to #{@to}!"
    end
    receiver = double(:receiver)
    @delegator.stub(@to).and_return(receiver)
    called = false
    receiver.stub(@method){ called = true }
    @delegator.send(@method, 1)
    called
  end

  description do
    "delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should do |text|
    "expected #{@delegator} to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should_not do |text|
    "expected #{@delegator} not to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  chain(:to) { |receiver| @to = receiver }
  chain(:with_prefix) { @prefix = true }
end


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
