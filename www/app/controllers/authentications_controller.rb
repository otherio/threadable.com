class AuthenticationsController < ApplicationController

  def new
  end

  def create
    authenticate(
      params[:authentication][:email],
      params[:authentication][:password]
    ) or flash[:error] = 'Login Failed'
    redirect_to root_url
  end

  def destroy
    session.delete(:current_user_id)
    redirect_to root_url
  end

end
