class Threadable::Emails

  InvalidEmail = Class.new(StandardError)

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def send_email type, *args
    email = generate(type, *args)
    Honeybadger.context({
      email_message: email.to_s,
      smtp_envelope_from: email.smtp_envelope_from,
      smtp_envelope_to: email.smtp_envelope_to,
    })
    Threadable::Emails::Validate.call(email)
    return if email.smtp_envelope_to =~ /(@|\.)example\.com$/
    email.deliver
  end

  def send_email_async type, *args
    type?(type)
    Threadable.after_transaction do
      SendEmailWorker.perform_async(threadable.env, type, *args)
    end
  end

  def generate type, *args
    type?(type)
    types[type.to_sym].new(threadable).generate(type.to_sym, *args)
  end

  private

  def types
    {
      conversation_message:       ConversationMailer,
      join_notice:                OrganizationMembershipMailer,
      unsubscribe_notice:         OrganizationMembershipMailer,
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