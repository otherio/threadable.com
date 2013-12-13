require 'sidekiq/worker'

class Covered::Worker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform covered_env, *args
    @covered = Covered.new(covered_env.symbolize_keys)
    begin
      perform!(*args)
    rescue Exception => exception
      @covered.report_exception! exception
      raise
    end
  end
  attr_reader :covered
  delegate :current_user, to: :covered

end
