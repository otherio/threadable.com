class Threadable::MixpanelTracker < Threadable::Tracker

  def track event_name, event_attributes
    recover_from_expected_errors do
      event_attributes.merge! via: threadable.worker ? 'email' : 'web'
      mixpanel.track(threadable.current_user_id, *[event_name, event_attributes])
    end
  end

  def track_user_change user
    recover_from_expected_errors do
      mixpanel.people.set(user.id, {
        '$name'    => user.name,
        '$email'   => user.email_address.to_s,
        '$created' => user.created_at.try(:iso8601),
      })
    end
  end

  private

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new(ENV.fetch('MIXPANEL_TOKEN'))
  end

  def recover_from_expected_errors
    yield
  rescue Errno::ECONNRESET => error
    threadable.report_exception!(error)
  ensure
    return nil
  end

end
