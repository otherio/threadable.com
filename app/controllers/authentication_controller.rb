class AuthenticationController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  layout 'outside'

  def show
    @notice = params[:notice]
    if signed_in?
      redirect_to redirect_url
    else
      @authentication    = Authentication.new(threadable, email_address: params[:email_address])
      @password_recovery = PasswordRecovery.new(email_address: params[:email_address])
    end
  end

  def sign_in
    sign_out! if signed_in?
    authentication_params = params.require(:authentication).slice(:email_address, :password, :remember_me)
    @authentication    = Authentication.new(threadable, authentication_params)
    @password_recovery = PasswordRecovery.new(email_address: authentication_params[:email_address])

    respond_to do |format|
      if @authentication.valid?
        sign_in! @authentication.user, remember_me: @authentication.remember_me
        format.html { redirect_to redirect_url }
        format.json { render json: nil }
      else
        @warning = 'Bad email address or password'
        format.html { render :show }
        format.json { render json: {error: @warning}, status: :unauthorized }
      end
    end
  end

  def recover_password
    email_address = params[:password_recovery].try(:[], :email_address)
    @password_recovery = PasswordRecovery.new(email_address: email_address)
    @authentication    = Authentication.new(threadable, email_address: email_address)

    user = threadable.users.find_by_email_address(email_address)

    case
    when user && user.web_enabled?
      threadable.emails.send_email_async(:reset_password, user.id)
    when user
      threadable.emails.send_email_async(:reset_password, user.id)
    end

    @success = "We've emailed you a password reset link."

    render :show
  end

  def sign_out
    sign_out!
    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.json { render nothing: true }
    end
  end

  private

  def redirect_url
    params[:r].presence || root_url
  end

end
