class Covered::Emails

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def send_email type, *args
    email = generate(type, *args)
    Honeybadger.context({
      email_message: email.to_s,
      smtp_envelope_from: email.smtp_envelope_from,
      smtp_envelope_to: email.smtp_envelope_to,
    })
    email.deliver! unless email.smtp_envelope_to =~ /\Wexample\.com$/
  end

  def send_email_async type, *args
    type?(type)
    Covered.after_transaction do
      SendEmailWorker.perform_async(covered.env, type, *args)
    end
  end

  def generate type, *args
    type?(type)
    types[type.to_sym].new(covered).generate(type.to_sym, *args)
  end

  private

  def types
    {
      conversation_message:       ConversationMailer,
      join_notice:                ProjectMembershipMailer,
      unsubscribe_notice:         ProjectMembershipMailer,
      sign_up_confirmation:       UserMailer,
      reset_password:             UserMailer,
      email_address_confirmation: UserMailer,
      message_held_notice:        IncomingEmailMailer,
      message_rejected_notice:    IncomingEmailMailer,
      message_accepted_notice:    IncomingEmailMailer,
    }
  end

  def type? type
    types.key?(type.to_sym) or raise ArgumentError, "unknown email type: #{type}"
  end

end
