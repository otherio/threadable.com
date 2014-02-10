class Threadable::IncomingEmails::Create < MethodObject

  def call incoming_emails, mailgun_params
    threadable = incoming_emails.threadable
    mailgun_params.stringify_keys!
    recipients = mailgun_params['recipient'].split(',').map{ |address| address.strip }

    recipients.map do |recipient|
      params = mailgun_params
      params['recipient'] = recipient
      incoming_email_record = ::IncomingEmail.create!(params: params)
      Threadable.after_transaction do
        ProcessIncomingEmailWorker.perform_async(threadable.env, incoming_email_record.id)
      end
      Threadable::IncomingEmail.new(threadable, incoming_email_record)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise Threadable::RecordInvalid, e.message
  end

end
