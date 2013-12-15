class Covered::MixpanelTracker < Covered::Tracker

  def track event_name, event_attributes
    event_attributes.merge! via: covered.worker ? 'email' : 'web'
    mixpanel.track(covered.current_user_id, *[event_name, event_attributes])
    nil
  end

  def track_user_change user
    mixpanel.people.set(user.id, {
      '$name'    => user.name,
      '$email'   => user.email_address,
      '$created' => user.created_at.try(:iso8601),
    })
    nil
  end

  private

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new(ENV.fetch('MIXPANEL_TOKEN'))
  end

end
