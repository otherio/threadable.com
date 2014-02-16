class SendSummaryEmailWorker < Threadable::ScheduledWorker
  recurrence backfill: true do
    daily.hour_of_day(10)  # 2am PST
  end

  def perform! last_time, time
    threadable.organizations.all.each do |organization|
      members = organization.members.who_get_summaries

      members.each do |member|
        threadable.emails.send_email_async(:message_summary, organization.id, member.user_id, time.in_time_zone('US/Pacific') - 1.day)
      end
    end
  end
end
