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

  def increment properties
    increment_for_user tracking_id, properties
  end

  def track_for_user user_id, event_name, event_attributes={}
    recover_from_expected_errors do
      fake_track
    end
    trackings << [user_id, event_name.to_s, event_attributes.stringify_keys]
    Rails.logger.info "TRACKING: #{trackings.last.inspect}"
    nil
  end

  def set_properties_for_user tracking_id, properties
    recover_from_expected_errors do
      fake_track
    end
    people[tracking_id] ||= {}
    people[tracking_id].update(properties)
    nil
  end

  def increment_for_user tracking_id, properties
    recover_from_expected_errors do
      fake_track
    end
    people[tracking_id] ||= {}

    properties.keys.each do |key|
      people[tracking_id][key] ||= 0
      people[tracking_id][key] += properties[key]
    end
  end

  def track_user_change user
    user_changes << user
    set_properties_for_user(user.id,
      '$user_id'       => user.id,
      '$name'          => user.name,
      '$email'         => user.email_address.to_s,
      '$created'       => user.created_at.try(:iso8601),
      'Owner'          => user.organization_owner,
      'Web Enabled'    => user.web_enabled?,
      'Munge Reply-to' => user.munge_reply_to?,
    )
    Rails.logger.info "TRACKING USER CHANGE FOR: #{user.inspect}"
    nil
  end

  def refresh_user_record user
    user_changes << user
    set_properties_for_user(user.id,
      '$user_id'          => user.id,
      '$name'             => user.name,
      '$email'            => user.email_address.to_s,
      '$created'          => user.created_at.try(:iso8601),
      '$ignore_time'      => true,
      'Owner'             => user.organization_owner,
      'Web Enabled'       => user.web_enabled?,
      'Munge Reply-to'    => user.munge_reply_to?,
      'Composed Messages' => user.messages.count,
    )
    Rails.logger.info "REFRESHING USER RECORD FOR: #{user.inspect}"
    nil
  end

  def fake_track
    # stub this if you want to raise an exception in your integration test
  end

  private

  def recover_from_expected_errors
    retries ||= 0
    yield
    return nil
  rescue Mixpanel::ConnectionError, OpenSSL::SSL::SSLError, Net::ReadTimeout, Errno::ECONNRESET, EOFError => error
    threadable.report_exception!(error)
    retries = retries + 1
    retry if retries <= 2
    return nil
  end


end
