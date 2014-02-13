class SendSummaryEmailWorker < Threadable::Worker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(10) }  # 2am PST

  def perform! last_time, time
    # get all the users who have summaries enabled for anything
    threadable.organizations.all.each do |organization|
      members = organization.members.who_get_summaries

      members.each do |member|
        threadable.emails.send_email_async(:message_summary, organization.id, member.user_id, time.in_time_zone('US/Pacific'))
      end
    end
  end
end
