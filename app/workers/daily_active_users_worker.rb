class DailyActiveUsersWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(7)  # 11pm PST
  end

  def perform! last_time, time
    threadable.organizations.with_subscription.each do |organization|
      billforward = Threadable::Billforward.new(organization: organization)
      billforward.update_member_count
    end
  end
end
