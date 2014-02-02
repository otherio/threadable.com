require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::Bounce < MethodObject

  def call incoming_email
    @incoming_email = incoming_email
    # actually bounce this message before deleting
    @incoming_email.bounced!
  end

end
