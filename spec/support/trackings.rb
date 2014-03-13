module RSpec::Support::Trackings

  def trackings
    Threadable::InMemoryTracker.trackings
  end

  def tracked_user_changes
    Threadable::InMemoryTracker.user_changes
  end

  def assert_tracked user_id, event, params=anything
    case params
    when anything
      trackings = self.trackings.map{|t| t.first(2) }
      tracking = [user_id, event.to_s]
    else
      trackings = self.trackings
      tracking = [user_id, event.to_s, params.stringify_keys]
    end
    trackings.include?(tracking) or raise RSpec::Expectations::ExpectationNotMetError,
      "expected to find the tracking:\n#{tracking.inspect}\nin\n#{trackings.map(&:inspect).join("\n")}", caller(1)
  end

  def assert_not_tracked user_id, event, params=anything
    case params
    when anything
      trackings = self.trackings.map{|t| t.first(2) }
      tracking = [user_id, event.to_s]
    else
      trackings = self.trackings
      tracking = [user_id, event.to_s, params.stringify_keys]
    end
    trackings.exclude?(tracking) or raise RSpec::Expectations::ExpectationNotMetError,
      "expected not to find the tracking:\n#{tracking.inspect}\nin\n#{trackings.map(&:inspect).join("\n")}", caller(1)
  end

end
