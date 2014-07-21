require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::Bounce < MethodObject

  def call incoming_email
    @incoming_email = incoming_email
    threadable = incoming_email.threadable

    threadable.emails.send_email(:message_bounced_dsn, @incoming_email)
    @incoming_email.bounced!
  end

end
