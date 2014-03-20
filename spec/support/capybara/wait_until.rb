module RSpec::Support::Capybara

  def wait_until_expectation
    exception = nil
    begin
      page.current_scope.synchronize do
        begin
          yield
        rescue RSpec::Expectations::ExpectationNotMetError => e
          exception = e
          raise Capybara::ExpectationNotMet
        end
      end
    rescue Capybara::ExpectationNotMet
      raise exception
    end
  end

  def wait_until
    begin
      page.current_scope.synchronize do
        yield or raise Capybara::ExpectationNotMet
      end
      return true
    rescue Capybara::ExpectationNotMet
      return false
    end
  end

end
