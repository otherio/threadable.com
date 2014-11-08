class DailyConversationActivityWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(12)  # 4am PST
  end

  attr_reader :organization

  def perform! last_time, time
    return unless ENV['CLOSEIO_API_KEY'].present?

    # active since the last run
    threadable.organizations.with_last_message_between(last_time, time).each do |organization|
      organization.update_recent_closeio_activity!
    end

    # 5 day rolling window
    threadable.organizations.with_last_message_between(last_time - 1.month, time - 1.month + 5.days).each do |organization|
      organization.update_recent_closeio_activity!
    end
  end
end
