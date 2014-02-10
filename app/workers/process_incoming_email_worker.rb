class ProcessIncomingEmailWorker < Threadable::Worker

  def perform! incoming_email_id
    @incoming_email = threadable.incoming_emails.find_by_id!(incoming_email_id)

    processing! or begin
      logger.warn("Rescheduling ProcessIncomingEmailWorker job. MessageId: #{@incoming_email.message_id}")
      reschedule_for 5.seconds.from_now
      return
    end

    begin
      @incoming_email.process!
    ensure
      done_processing!
    end
  end

  def redis_key
    @redis_key ||= "#{self.class}:#{@incoming_email.message_id}"
  end

  def processing!
    Threadable.redis.setnx(redis_key, Time.now.to_i) and \
    Threadable.redis.expire(redis_key, 30) # seconds
  end

  def done_processing!
    Threadable.redis.del(redis_key)
  end

end
