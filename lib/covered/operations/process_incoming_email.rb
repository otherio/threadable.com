class Covered::Operations::ProcessIncomingEmail < Covered::Operation

  require_option :email

  def call
    Covered.create_message_from_incoming_email(:email => @email)
  end

end
