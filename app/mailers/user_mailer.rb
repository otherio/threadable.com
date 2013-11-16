class UserMailer < Covered::Mailer

  def sign_up_confirmation(options)
    @recipient = Covered::User.find options[:recipient_id]
    user_confirmation_token = UserConfirmationToken.encrypt(@recipient.id)
    @account_confirmation_url = confirm_users_url(user_confirmation_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    from_address,
      subject: "Welcome to Covered!",
    )
  end

  def reset_password(options)
    @recipient = Covered::User.find options[:recipient_id]
    reset_password_token = ResetPasswordToken.encrypt(@recipient.id)
    @reset_password_url = reset_password_url(reset_password_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    from_address,
      subject: "Reset your password!",
    )
  end

  private

  def from_address
    "no-reply@#{url_options[:host]}"
  end

end
