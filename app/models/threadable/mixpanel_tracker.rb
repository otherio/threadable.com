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

  def track_for_user tracking_id, event_name, event_attributes={}
    recover_from_expected_errors do
      event_attributes.merge! via: threadable.worker ? 'email' : 'web'
      mixpanel.track(tracking_id, event_name, event_attributes)
    end
  end

  def set_properties_for_user tracking_id, properties
    recover_from_expected_errors do
      mixpanel.people.set(tracking_id, properties)
    end
  end

  def track_user_change user
    raise "user must have a user id to track changes" unless user.id.present?
    set_properties_for_user(user.id,
      '$user_id' => user.id,
      '$name'    => user.name,
      '$email'   => user.email_address.to_s,
      '$created' => user.created_at.try(:iso8601),
    )
  end

  private

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new(ENV.fetch('MIXPANEL_TOKEN'))
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
