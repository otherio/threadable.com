class IdentifyCoveredEmailAddress < MethodObject

  def call email_address
    Covered::Class::EMAIL_HOSTS.values.include? email_address.domain
  end

end
