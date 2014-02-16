require 'sidekiq/worker'

class Threadable::ScheduledWorker < Threadable::Worker
  include Sidetiq::Schedulable

  def perform last_run = -1, this_run = nil
    # if the job is manually triggered, it won't get any times
    this_run = this_run.present? ? float_to_time(this_run) : Time.now.utc

    @threadable = Threadable.new(threadable_env)

    super threadable_env, float_to_time(last_run), this_run
  end

  private

  def threadable_env
    {
      host:     Rails.application.config.default_host,
      port:     Rails.application.config.default_port,
      protocol: Rails.application.config.default_protocol,
      worker:   true,
    }
  end

  def float_to_time ftime
    return nil if ftime <= 0
    # http://stackoverflow.com/questions/18707335/ruby-time-object-converted-from-float-doesnt-equal-to-orignial-time-object
    Time.at(ftime.to_r)
  end

end
