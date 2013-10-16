class UserMailer < ActionMailer::Base

  def sign_up_confirmation user
    user_confirmation_token = UserConfirmationToken.encrypt(user.id)
    @account_confirmation_url = confirm_users_url(user_confirmation_token)
    host = url_options.values_at(:host, :port).join(':')
    mail(
      to:      user.formatted_email_address,
      from:    "no-reply@#{host}",
      subject: "Welcome to Covered!",
    )
  end

end
