class Threadable::IncomingEmails::Create < MethodObject

  def call incoming_emails, mailgun_params
    threadable = incoming_emails.threadable
    incoming_email_record = ::IncomingEmail.create!(params: mailgun_params)
    Threadable.after_transaction do
      ProcessIncomingEmailWorker.perform_async(threadable.env, incoming_email_record.id)
    end
    Threadable::IncomingEmail.new(threadable, incoming_email_record)
  rescue ActiveRecord::RecordInvalid => e
    raise Threadable::RecordInvalid, e.message
  end

end
