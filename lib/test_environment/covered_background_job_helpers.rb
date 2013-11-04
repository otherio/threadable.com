require 'sidekiq/testing'
Sidekiq::Testing.fake!

module TestEnvironment::CoveredBackgroundJobHelpers

  def background_jobs
    Covered::BackgroundJobs::Worker.jobs.map do |job|
      env, operation_name, options = job["args"]
      {
        'env' => env,
        'operation_name' => operation_name,
        'options' => options,
      }
    end
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

  def run_background_jobs!
    jobs = Covered::BackgroundJobs::Worker.jobs.dup
    Covered::BackgroundJobs::Worker.jobs.clear
    jobs.each do |job|
      worker = Covered::BackgroundJobs::Worker.new
      worker.jid = job['jid']
      worker.perform(*job['args'])
    end
    jobs
  end

  def drain_background_jobs!
    run_background_jobs! until Covered::BackgroundJobs::Worker.jobs.empty?
  end

end
