class Threadable::InMemoryTracker < Threadable::Tracker

  @store = {}

  def self.trackings
    @store[:trackings] ||= []
  end

  def self.user_changes
    @store[:user_changes] ||= []
  end

  def self.clear
    @store.clear
  end

  delegate :trackings, :user_changes, :clear, to: :class

  def track event, params={}
    trackings << [threadable.current_user_id, event.to_s, params.stringify_keys]
    Rails.logger.info "TRACKING: #{trackings.last.inspect}"
    nil
  end

  def track_user_change user
    user_changes << user
    Rails.logger.info "TRACKING USER CHANGE FOR: #{user.inspect}"
    nil
  end

end
