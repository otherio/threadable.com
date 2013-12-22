class UserMailer < Covered::Mailer

  def sign_up_confirmation(recipient)
    @recipient = recipient

    @confirm_email_address_url = confirm_email_address_url(EmailAddressConfirmationToken.encrypt(@recipient.email_address.id))

    mail(
      to:      @recipient.formatted_email_address,
      from:    from_address,
      subject: "Welcome to Covered!",
    )
  end

  def reset_password recipient
    @recipient = recipient
    reset_password_token = ResetPasswordToken.encrypt(@recipient.id)
    @reset_password_url = reset_password_url(reset_password_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    from_address,
      subject: "Reset your password!",
    )
  end

  def email_address_confirmation email_address
    @email_address = email_address
    @confirm_email_address_url = confirm_email_address_url(EmailAddressConfirmationToken.encrypt(@email_address.id))
    mail(
      to:      @email_address.formatted_email_address,
      from:    "Covered email address confirmation request <support+email-address-confirmation-request@#{covered.email_host}",
      subject: "Please confirm your email address",
    )
  end

  private

  def from_address
    "no-reply@#{url_options[:host]}"
  end

end
