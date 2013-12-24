class UserMailer < Covered::Mailer

  def sign_up_confirmation(recipient)
    @recipient = recipient

    @confirm_email_address_url = confirm_email_address_url(EmailAddressConfirmationToken.encrypt(@recipient.email_address.id))

    mail(
      to:      @recipient.formatted_email_address,
      from:    "Covered welcome <#{covered.support_email_address('welcome')}>",
      subject: "Welcome to Covered!",
    )
  end

  def reset_password recipient
    @recipient = recipient
    reset_password_token = ResetPasswordToken.encrypt(@recipient.id)
    @reset_password_url = reset_password_url(reset_password_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    "Covered password reset <#{covered.support_email_address('password-reset')}>",
      subject: "Reset your password!",
    )
  end

  def email_address_confirmation email_address
    @email_address = email_address
    @confirm_email_address_url = confirm_email_address_url(EmailAddressConfirmationToken.encrypt(@email_address.id))
    mail(
      to:      @email_address.formatted_email_address,
      from:    "Covered email address confirmation request <#{covered.support_email_address('email-address-confirmation')}>",
      subject: "Please confirm your email address",
    )
  end

end
