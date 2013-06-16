module TestEnvironment::IncomingEmailParams

  def create_incoming_email_params(overides={})
    ::TestEnvironment::IncomingEmailParamsFactory.call(overides)
  end

end
