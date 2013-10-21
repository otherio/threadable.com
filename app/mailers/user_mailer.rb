class UserMailer < ActionMailer::Base

  def sign_up_confirmation user
    user_confirmation_token = UserConfirmationToken.encrypt(user.id)
    @account_confirmation_url = confirm_users_url(user_confirmation_token)

    mail(
      to:      user.formatted_email_address,
      from:    from_address,
      subject: "Welcome to Covered!",
    )
  end

  def reset_password user
    reset_password_token = ResetPasswordToken.encrypt(user.id)
    @reset_password_url = reset_password_url(reset_password_token)
    mail(
      to:      user.formatted_email_address,
      from:    from_address,
      subject: "Reset your password!",
    )
  end

  private

  def from_address
    "no-reply@#{host_with_port}"
  end

  def host_with_port
    @host_with_port ||= begin
      host, port = url_options.values_at(:host, :port)
      port.present? ? "#{host}:#{port}" : host
    end
  end

end
