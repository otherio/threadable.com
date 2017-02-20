require 'sidekiq/worker'

class Threadable::Worker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

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

    threadable.refresh
  end
  attr_reader :threadable
  delegate :current_user, to: :threadable
  delegate :logger, to: ::Rails


  # reschedule_for 5.seconds.from_now
  def reschedule_for time
    self.class.perform_at(time, *@original_args)
  end

  def default_url_options
    { host: threadable.host, port: threadable.port }
  end
end
