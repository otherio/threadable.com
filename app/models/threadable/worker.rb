require 'sidekiq/worker'

class Threadable::Worker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform threadable_env, *args
    @original_args = [threadable_env, *args]

    @threadable = Threadable.new(threadable_env.symbolize_keys.merge({worker: true}))
    begin
      Threadable.transaction do
        perform!(*args)
      end
    rescue Exception => exception
      @threadable.report_exception! exception
      raise
    end
  end
  attr_reader :threadable
  delegate :current_user, to: :threadable
  delegate :logger, to: ::Rails


  # reschedule_for 5.seconds.from_now
  def reschedule_for time
    self.class.perform_at(time, *@original_args)
  end

end
