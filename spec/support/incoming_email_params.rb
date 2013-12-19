module RSpec::Support::IncomingEmailParams

  def create_incoming_email_params options={}
    IncomingEmailParamsFactory.call(options)
  end

end
