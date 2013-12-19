module RSpec::Support::BackgroundJobs

  def background_job_workers
    Covered::Worker.descendants
  end

  def background_jobs
    background_job_workers.map(&:jobs).flatten(1)
  end

  def clear_background_jobs!
    background_job_workers.each{|worker| worker.jobs.clear}
  end

  def run_background_jobs!
    jobs = background_jobs
    clear_background_jobs!
    jobs.each{ |job| run_background_job job }
  end

  def run_background_job job
    worker = job["class"].constantize.new
    worker.jid = job['jid']
    worker.perform(*job['args'])
  end

  def drain_background_jobs!
    run_background_jobs! until background_jobs.empty?
  end

  def find_background_jobs worker, options={}
    unknown_options = options.keys - [:args]
    raise ArgumentError, "unknown options #{unknown_options.inspect}" unless unknown_options.empty?

    background_jobs.find_all do |job|
      job["class"] == worker.name or next false
      if options.has_key? :args
        job["args"] == options[:args] or next false
      end
      next true
    end
  end

  def assert_background_job_enqueued worker, options={}
    find_background_jobs(worker, options).present? or raise RSpec::Expectations::ExpectationNotMetError,
      "expected to find background job\n#{worker.inspect}\n#{options.inspect}\nin\n#{background_jobs.inspect}", caller(1)
  end

  def assert_background_job_not_enqueued worker, options={}
    find_background_jobs(worker, options).empty? or raise RSpec::Expectations::ExpectationNotMetError,
      "expected not to find background job\n#{worker.inspect}\n#{options.inspect}\nin\n#{background_jobs.inspect}", caller(1)
  end

end
