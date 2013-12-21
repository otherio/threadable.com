class Covered::IncomingEmails::Create < MethodObject

  def call incoming_emails, mailgun_params
    covered = incoming_emails.covered
    incoming_email_record = ::IncomingEmail.create!(params: mailgun_params)
    Covered.after_transaction do
      ProcessIncomingEmailWorker.perform_async(covered.env, incoming_email_record.id)
    end
    Covered::IncomingEmail.new(covered, incoming_email_record)
  rescue ActiveRecord::RecordInvalid => e
    raise Covered::RecordInvalid, e.message
  end

end
