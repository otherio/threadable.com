class AuthenticationsController < ApplicationController

  def create
    id = Multify::User.authenticate(
      email: params[:authentication][:email],
      password: params[:authentication][:password]
    )

    if id.present?
      session[:current_user_id] = id
    else
      flash[:error] = 'Login Failed'
    end

    redirect_to root_url
  end

  def destroy
    session.delete(:current_user_id)
    redirect_to root_url
  end

end
