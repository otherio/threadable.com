require_dependency 'covered/incoming_email'

class Covered::IncomingEmail::Bounce < MethodObject

  def call incoming_email
    @incoming_email = incoming_email
    # actually bounce this message before deleting
    @incoming_email.bounced!
  end

end
