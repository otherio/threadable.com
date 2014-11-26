class Threadable::MixpanelTracker < Threadable::Tracker

  def bind_tracking_id_to_user_id! user_id
    recover_from_expected_errors do
      mixpanel.alias(user_id, tracking_id)
    end
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

  def track_for_user tracking_id, event_name, event_attributes={}
    recover_from_expected_errors do
      event_attributes.merge! via: threadable.worker ? 'email' : 'web'
      mixpanel.track(tracking_id, event_name, event_attributes)
    end
  end

  def set_properties_for_user tracking_id, properties
    flags = properties.extract!('$ignore_time')

    recover_from_expected_errors do
      mixpanel.people.set(tracking_id, properties, ip(tracking_id), flags)
    end
  end

  def increment_for_user tracking_id, properties
    recover_from_expected_errors do
      mixpanel.people.increment(tracking_id, properties, ip(tracking_id))
    end
  end

  def track_user_change user
    raise "user must have a user id to track changes" unless user.id.present?
    set_properties_for_user(user.id,
      '$user_id'       => user.id,
      '$name'          => user.name,
      '$email'         => user.email_address.to_s,
      '$created'       => user.created_at.try(:iso8601),
      'Owner'          => user.organization_owner,
      'Web Enabled'    => user.web_enabled?,
      'Munge Reply-to' => user.munge_reply_to?,
    )
  end

  def refresh_user_record user
    raise "user must have a user id to track changes" unless user.id.present?
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
  end

  private

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new(ENV.fetch('MIXPANEL_TOKEN'))
  end

  def ip tracking_id = nil
    forwarded_for = ENV.fetch('HTTP_X_FORWARDED_FOR', nil)
    if forwarded_for && threadable.current_user_id.present? && threadable.current_user_id == tracking_id
      forwarded_for.split(/,\s*/).last
    else
      '0'
    end
  end

  def recover_from_expected_errors
    retries ||= 0
    yield
    return nil
  rescue Mixpanel::ConnectionError, OpenSSL::SSL::SSLError, Net::ReadTimeout, Errno::ECONNRESET => error
    threadable.report_exception!(error)
    retries = retries + 1
    retry if retries <= 2
    return nil
  end

end
