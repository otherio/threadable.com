class Covered::InMemoryTracker < Covered::Tracker

  @store = {}

  def self.trackings
    @store[:trackings] ||= []
  end

  def self.tracked_users_changes
    @store[:tracked_users_changes] ||= []
  end

  def self.clear
    @store.clear
  end

  delegate :trackings, :tracked_users_changes, :clear, to: :class

  def track *args
    trackings << args
    nil
  end

  def track_user_change user
    tracked_users_changes << user
    nil
  end

end
