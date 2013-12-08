class ProcessIncomingEmailWorker < Covered::Worker

  def perform! incoming_email_id
    incoming_email = covered.incoming_emails.find_by_id!(incoming_email_id)
    incoming_email.reset!
    incoming_email.process!
  end

end
