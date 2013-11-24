class ProcessIncomingEmailWorker < Covered::Worker

  def perform! incoming_email_id
    covered.process_incoming_email IncomingEmail.find(incoming_email_id)
  end

end
