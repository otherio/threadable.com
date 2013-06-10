class ProcessEmailWorker < ResqueWorker.new(:params)

  queue :incoming_mail

  def call
    EmailProcessor.call(@params)
  end

end

