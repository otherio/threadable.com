class ProcessEmailWorker < ResqueWorker.new(:email)

  def call
    EmailProcessor.process_email(@email)
  end

end

