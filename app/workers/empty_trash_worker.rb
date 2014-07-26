class EmptyTrashWorker < Threadable::ScheduledWorker
  recurrence do
    daily.hour_of_day(10)  # 2am PST
  end

  def perform! last_time, time
    threadable.conversations.to_be_deleted.each do |conversation|
      conversation.destroy!
    end
  end
end
