class ProcessEmailWorker < ResqueWorker.new(:email, :stripped)

  queue :incoming_mail

  def call
    EmailProcessor.process_email(@email, @stripped)
  end

end

