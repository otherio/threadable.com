class AuthenticationController < ApplicationController

  PADU = :post_authentication_destination_url

  def new
    session[PADU] = params[:r] || session[PADU]
    if signed_in?
      redirect_to redirect_url!
    else
      @email = params[:email]
    end
  end

  def create
    authentication_params = params.require(:authentication).permit(:email, :password, :remember_me)
    authentication = Authentication.new(authentication_params)
    if authentication.valid?
      sign_in! authentication.user, remember_me: authentication.remember_me
      render json: {redirect_to: redirect_url!}
    else
      render json: {fail: true, error: authentication.errors.full_messages.to_sentence}
    end
  end

  def destroy
    sign_out!
    redirect_to redirect_url!
  end

  private

  def redirect_url!
    session.delete(PADU) || root_url
  end

end
