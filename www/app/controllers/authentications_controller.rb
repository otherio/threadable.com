class AuthenticationsController < ApplicationController

  def new
  end

  def create
    begin
      authentication_token, user = Multify.authenticate(
        params[:authentication][:email],
        params[:authentication][:password]
      )
      authenticate(authentication_token, user.id)
    rescue RestClient::ResourceNotFound
      flash[:error] = 'Login Failed'
    ensure
      redirect_to root_url
    end
  end

  def destroy
    session.delete(:current_user_id)
    redirect_to root_url
  end

end
