class SendSummaryEmailWorker < Threadable::Worker

  def perform! time
    # get all the users who have summaries enabled for anything
    threadable.organizations.all.each do |organization|
      members = organization.members.who_get_summaries

      members.each do |member|
        threadable.emails.send_email_async(:message_summary, organization.id, member.user_id, time)
      end
    end
  end
end
