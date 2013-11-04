class Users::SetupController < ApplicationController

  before_filter :require_valid_token!

  def edit
    @user = Covered::User.find(@user_id)
  end

  def update
    if user.update_attributes(user_params)
      flash[:notice] = %(You're all setup! Welcome to Covered.)
      sign_in! user
      redirect_to @destination_path || root_path
    else
      render :edit
    end
  end

  private

  def require_valid_token!
    unauthorized! unless token.present?
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
    @user ||= Covered::User.find(@user_id)
  end

end
