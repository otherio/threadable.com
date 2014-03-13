class ProcessIncomingIntegrationHookWorker < Threadable::Worker

  def perform! incoming_integration_hook_id
    @incoming_integration_hook = threadable.incoming_integration_hooks.find_by_id!(incoming_integration_hook_id)

    processing! or begin
      logger.warn("Rescheduling ProcessIncomingIntegrationHookWorker job. External Message ID: #{@incoming_integration_hook.external_message_id}")
      reschedule_for 5.seconds.from_now
      return
    end

    begin
      @incoming_integration_hook.process!
    ensure
      done_processing!
    end
  end

  def redis_key
    @redis_key ||= "#{self.class}:#{@incoming_integration_hook.provider}-#{@incoming_integration_hook.external_message_id}"
  end

  def processing!
    Threadable.redis.setnx(redis_key, Time.now.to_i) and \
    Threadable.redis.expire(redis_key, 30) # seconds
  end

  def done_processing!
    Threadable.redis.del(redis_key)
  end

end
