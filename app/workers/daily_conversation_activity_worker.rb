class DailyConversationActivityWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(12)  # 4am PST
  end

  attr_reader :organization

  def perform! last_time, time
    threadable.organizations.with_last_message_between(last_time, time).each do |organization|
      update_recent_activity organization, 'yes'
    end

    # 5 day rolling window
    threadable.organizations.with_last_message_between(last_time - 1.month, time - 1.month + 5.days).each do |organization|
      update_recent_activity organization, 'no'
    end
  end
end

def update_recent_activity organization, activity
  lead = organization.find_closeio_lead
  if lead
    Closeio::Lead.update lead.id, 'custom.recent_activity' => activity
  else
    organization.create_closeio_lead!
  end
end
