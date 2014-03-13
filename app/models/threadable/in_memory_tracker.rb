class Threadable::InMemoryTracker < Threadable::Tracker

  @store = {}

  def self.trackings
    @store[:trackings] ||= []
  end

  def self.user_changes
    @store[:user_changes] ||= []
  end

  def self.aliases
    @store[:aliases] ||= {}
  end

  def self.people
    @store[:people] ||= {}
  end

  def self.clear
    @store.clear
  end

  delegate :trackings, :user_changes, :aliases, :people, :clear, to: :class

  def bind_tracking_id_to_user_id! user_id
    raise "user #{user_id.inspect} already has an alias" if aliases.key?(user_id)
    raise "tracking id #{threadable.tracking_id.inspect} is already an alias" if aliases.values.include?(threadable.tracking_id)
    aliases[user_id] = threadable.tracking_id
  end

  def track event_name, event_attributes={}
    track_for_user tracking_id, event_name, event_attributes
  end

  def set_properties properties
    set_properties_for_user tracking_id, properties
  end

  def track_for_user user_id, event_name, event_attributes={}
    trackings << [user_id, event_name.to_s, event_attributes.stringify_keys]
    Rails.logger.info "TRACKING: #{trackings.last.inspect}"
    nil
  end

  def set_properties_for_user tracking_id, properties
    people[tracking_id] ||= {}
    people[tracking_id].update(properties)
    nil
  end

  def track_user_change user
    user_changes << user
    set_properties_for_user(user.id,
      '$user_id' => user.id,
      '$name'    => user.name,
      '$email'   => user.email_address.to_s,
      '$created' => user.created_at.try(:iso8601),
    )
    Rails.logger.info "TRACKING USER CHANGE FOR: #{user.inspect}"
    nil
  end

end
