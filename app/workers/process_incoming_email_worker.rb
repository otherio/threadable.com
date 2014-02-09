class ProcessIncomingEmailWorker < Threadable::Worker

  def perform! incoming_email_id
    @incoming_email = threadable.incoming_emails.find_by_id!(incoming_email_id)

    if duplicate_being_processed?
      logger.warn("Rescheduling ProcessIncomingEmailWorker job. MessageId: #{@incoming_email.message_id}")
      reschedule_for 5.seconds.from_now
      return
    end

    begin
      processing!
      @incoming_email.process!
    ensure
      done_processing!
    end
  end

  def redis_key
    @redis_key ||= "#{self.class}:#{@incoming_email.message_id}"
  end

  def duplicate_being_processed?
    Threadable.redis.exists(redis_key)
  end

  def processing!
    Threadable.redis.set(redis_key, Time.now.to_i)
    Threadable.redis.expire(redis_key, 30) # seconds
  end

  def done_processing!
    Threadable.redis.del(redis_key)
  end

end
