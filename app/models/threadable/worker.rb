require 'sidekiq/worker'

class Threadable::Worker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform threadable_env, *args

    @threadable = Threadable.new(threadable_env.symbolize_keys.merge({worker: true}))
    begin
      perform!(*args)
    rescue Exception => exception
      @threadable.report_exception! exception
      raise
    end
  end
  attr_reader :threadable
  delegate :current_user, to: :threadable

end
