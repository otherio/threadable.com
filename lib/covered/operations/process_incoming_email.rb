class Covered::Operations::ProcessIncomingEmail < Covered::Operation

  require_option :email

  def call
    Covered.process_incoming_email(:email => @email)
  end

end
