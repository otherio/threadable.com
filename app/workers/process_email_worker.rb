class ProcessEmailWorker < ResqueWorker.new(:email)

  queue :incoming_mail

  def call
    EmailProcessor.process_email(@email)
  end

end

