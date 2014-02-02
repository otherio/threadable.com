class Users::SetupController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :require_valid_token!

  def edit
    @user = User.find(@user_id)
  end

  def update
    if user.update_attributes(user_params)
      flash[:notice] = %(You're all setup! Welcome to Threadable.)
      sign_in! user
      redirect_to @destination_path || root_path
    else
      render :edit
    end
  end

  private

  def require_valid_token!
    unauthenticated! unless token.present?
  end

  def token
    return @token if defined?(@token)
    @token = params[:token] or return
    @user_id, @destination_path = UserSetupToken.decrypt(@token)
  rescue Token::Invalid
    @token = nil
  end

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def user
    @user ||= User.find(@user_id)
  end

end
