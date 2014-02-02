require 'validate_email_address'

class Threadable::Emails::Validate < MethodObject

  def call email
    @errors = []

    Array(email.smtp_envelope_from).each do |address|
      ValidateEmailAddress.call(address) or invalid! "envelope from address: #{address.inspect}"
    end

    Array(email.smtp_envelope_to).each do |address|
      ValidateEmailAddress.call(address) or invalid! "envelope to address: #{address.inspect}"
    end

    Array(email.from).each do |address|
      ValidateEmailAddress.call(address) or invalid! "from address: #{address.inspect}"
    end

    Array(email.to).each do |address|
      ValidateEmailAddress.call(address) or invalid! "to address: #{address.inspect}"
    end

    email.subject.present? or invalid! "subject: is blank"
  end

  def invalid! message
    raise Threadable::Emails::InvalidEmail, "invalid #{message}"
  end

end
