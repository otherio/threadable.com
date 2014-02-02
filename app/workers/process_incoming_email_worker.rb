class ProcessIncomingEmailWorker < Threadable::Worker

  def perform! incoming_email_id
    threadable.incoming_emails.find_by_id!(incoming_email_id).process!
  end

end
