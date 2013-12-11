module RSpec::Support::Trackings

  def trackings
    Covered::InMemoryTracker.trackings
  end

  def tracked_user_changes
    Covered::InMemoryTracker.user_changes
  end

  def assert_tracked user_id, event, params={}
    tracking = [user_id, event.to_s, params.stringify_keys]
    trackings.include?(tracking) or raise RSpec::Expectations::ExpectationNotMetError,
      "expected to find the tracking:\n#{tracking.inspect}\nin\n#{trackings.map(&:inspect).join("\n")}", caller(1)
  end

end
