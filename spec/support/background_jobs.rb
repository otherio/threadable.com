module RSpec::Support::BackgroundJobs

  def background_job_workers
    [
      SendEmailWorker,
      ProcessIncomingEmailWorker,
    ]
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

  def assert_background_job_enqueued covered, operation_name, options={}
    job = {
      'env' => covered.env,
      'operation_name' => operation_name,
      'options' => options,
    }

    job = MultiJson.decode MultiJson.encode job

    expect(background_jobs).to include job
  end

end
