class IdentifyThreadableEmailAddress < MethodObject

  def call email_address
    Threadable::Class::EMAIL_HOSTS.values.include? email_address.domain
  end

end
