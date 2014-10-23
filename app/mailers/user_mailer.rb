class UserMailer < Threadable::Mailer
  include Roadie::Rails::Automatic

  def sign_up_confirmation(organization_name, email_address)
    @organization_name = organization_name.to_s
    @email_address = email_address.to_s

    @confirm_sign_up_url = sign_up_confirmation_url(token: SignUpConfirmationToken.encrypt(@organization_name, @email_address))

    mail(
      to:      @email_address,
      from:    "Threadable <#{threadable.support_email_address('welcome')}>",
      subject: "Welcome to Threadable!",
    )
  end

  def reset_password recipient
    @recipient = recipient
    reset_password_token = ResetPasswordToken.encrypt(@recipient.id)
    @reset_password_url = reset_password_url(reset_password_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    "Threadable <#{threadable.support_email_address('password-reset')}>",
      subject: "Reset your password!",
    )
  end

  def email_address_confirmation email_address
    @email_address = email_address
    @confirm_email_address_url = confirm_email_address_url(EmailAddressConfirmationToken.encrypt(@email_address.id))
    mail(
      to:      @email_address.formatted_email_address,
      from:    "Threadable email address confirmation request <#{threadable.support_email_address('email-address-confirmation')}>",
      subject: "Please confirm your email address",
    )
  end

end
