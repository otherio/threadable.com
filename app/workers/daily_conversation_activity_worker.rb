class DailyConversationActivityWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(12)  # 4am PST
  end

  def perform! last_time, time
    binding.pry
    threadable.organizations.with_last_message_between(last_time, time).each do |organization|
      organization.update_daily_last_message_at!
      lead = organization.find_closeio_lead
      if lead
        Closeio::Lead.update lead.id, 'custom.recent_activity' => 'yes'
      else
        organization.create_closeio_lead!
      end
    end

    # condition here: org's last_message_at is < n months ago, but not > n months - 5.days ago
    # (so, we update close.io for an org for 5 days).
    # this runs after the above, so we don't run it for orgs that have new traffic.

    # threadable.organizations.
  end
end
