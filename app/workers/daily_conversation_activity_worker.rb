class DailyConversationActivityWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(12)  # 4am PST
  end

  attr_reader :organization

  def perform! last_time, time
    return unless ENV['CLOSEIO_API_KEY'].present?

    # active since the last run
    threadable.organizations.with_last_message_between(last_time, time).each do |organization|
      update_recent_activity organization
    end

    # 5 day rolling window
    threadable.organizations.with_last_message_between(last_time - 1.month, time - 1.month + 5.days).each do |organization|
      update_recent_activity organization
    end
  end
end

def update_recent_activity organization
  lead = organization.find_closeio_lead
  if lead
    Closeio::Lead.update(
      lead.id,
      'custom.recent_activity' => organization.has_recent_activity? ? 'yes' : 'no',
      'custom.last_message_at' => organization.last_message_at.strftime('%Y-%m-%d'),
    )
  else
    organization.create_closeio_lead!
  end
end
