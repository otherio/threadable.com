Covered::Operations.define :process_incoming_email do

  option :incoming_email_id, required: true

  let(:incoming_email){ IncomingEmail.find incoming_email_id }

  def call
    case
    when incoming_email.conversation_message?
      covered.create_message_from_incoming_email(:incoming_email_id => incoming_email.id)
    else
      raise "unknown incoming email type"
    end
  end

end

