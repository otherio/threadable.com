class Users::SetupController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :require_valid_token!

  def edit
    @was_confirmed = false
    unless user.confirmed?
      user.confirm!
      @was_confirmed = true
    end
    if user.web_enabled?
      redirect_to @destination_path
    else
      render :edit
    end
  end

  def update
    if user.update(user_params)
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
    @user ||= organization.members.find_by_user_id(@user_id)
  end

  def organization
    @organization ||= threadable.organizations.find_by_slug(Rails.application.routes.recognize_path(@destination_path)[:path])
  end

end
