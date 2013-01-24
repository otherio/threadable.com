module CapybaraEnvironment::WaitUntilExpectation

  # wait_until_expectation joins capybara's wait_until and rspec matchers
  #
  # Whats the difference?
  #   wait_until takes a block and executes it until it returns true for
  #   the length of the Capybara.default_wait_time.
  #
  #   wait_until_expectation takes a block and runs it until it doesn't
  #   raise an RSpec::Expectations::ExpectationNotMetError error
  #
  #   wait_until_expectation also raises the last exception from the given
  #   block rather then raisesin a Capybara::Timeout error
  #
  #   wait_until_expectation also invokes the debugger when an it times
  #   out if @debug is true
  def wait_until_expectation(timeout = Capybara.default_wait_time)
    begin
      exception = nil
      wait_until(timeout) do
        begin
          yield
          true
        rescue RSpec::Expectations::ExpectationNotMetError => e
          exception = e
          false
        end
      end
    rescue Capybara::TimeoutError
      if @debug
        debugger;1
      end
      raise exception
    end
  end

end
