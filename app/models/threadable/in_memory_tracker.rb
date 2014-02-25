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

  def track event_name, event_attributes={}
    track_for_user threadable.current_user_id, event_name, event_attributes
  end

  def track_for_user user_id, event_name, event_attributes={}
    trackings << [user_id, event_name.to_s, event_attributes.stringify_keys]
    Rails.logger.info "TRACKING: #{trackings.last.inspect}"
    nil
  end

  def track_user_change user
    user_changes << user
    Rails.logger.info "TRACKING USER CHANGE FOR: #{user.inspect}"
    nil
  end

end
