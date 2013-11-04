class PasswordController < ApplicationController

  def recover
    email = params.require(:password_recovery).require(:email)
    user = Covered::User.with_email(email).first

    case
    when user && user.has_password?
      # send password recovery email
      render json: {done: "We've emailed you a password recovery link. Please check your email."}
    when user
      # send account setup email
        # user_setup_token = UserSetupToken.encrypt(user.id, root_path)
        # render json: {redirect_to: user_setup_path(token: user_setup_token)}
      render json: {done: "We've emailed you a link to setup your account. Please check your email."}
    else
      # render error
      render json: {error: "No account found with that email address"}
    end
  end

end
