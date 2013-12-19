class RejectHeldIncomingEmailWorker < Covered::Worker

  def perform! incoming_email_id
    covered.incoming_emails.find_by_id!(incoming_email_id).reject!
  end

end
