class AuthenticationController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  PADU = :post_authentication_destination_url

  def new
    session[PADU] = params[:r] || session[PADU]
    if signed_in?
      redirect_to redirect_url!
    else
      @authentication    = Authentication.new(covered, email_address: params[:email_address])
      @password_recovery = PasswordRecovery.new(email_address: params[:email_address])
    end
  end

  def create
    authentication_params = params.slice(:email_address, :password, :remember_me)
    authentication = Authentication.new(covered, authentication_params)
    if authentication.valid?
      sign_in! authentication.user, remember_me: authentication.remember_me
      render json: nil
    else
      render json: {error: authentication.errors.full_messages.to_sentence}, status: :unauthorized
    end
  end

  def destroy
    sign_out!
    render nothing: true
  end

  private

  def redirect_url!
    session.delete(PADU) || root_url
  end

end
