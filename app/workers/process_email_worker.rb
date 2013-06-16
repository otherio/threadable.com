class ProcessEmailWorker < ResqueWorker.new(:params)

  queue :incoming_mail

  def call
    incoming_email = IncomingEmail.find(@params['incoming_email_id'])
    EmailProcessor.call(incoming_email)
  end

end

