class Users::SetupController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :require_valid_token!

  attr_reader :organization

  def edit
    @was_confirmed = false
    unless user.confirmed?
      user.confirm!
      @was_confirmed = true
    end
    if user.web_enabled?
      if signed_in? && user.id == current_user_id
        redirect_to organization_path(@organization)
      else
        redirect_to sign_in_path(r: organization_path(@organization))
      end
    else
      render :edit
    end
  end

  def update
    user.update(user_params)
    if user.errors.present?
      render :edit
    else
      sign_in! user
      redirect_to organization_path(@organization) || root_path
    end
  end

  private

  def require_valid_token!
    unauthenticated! unless token.present?
  end

  def token
    return @token if defined?(@token)
    @token = params[:token] or return
    @user_id, destination = UserSetupToken.decrypt(@token)
    if destination =~ /^\//
      @organization = threadable.organizations.find_by_slug(Rails.application.routes.recognize_path(destination)[:organization_id])
    else
      @organization = threadable.organizations.find_by_id(destination)
    end
  rescue Token::Invalid
    @token = nil
  end

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def user
    @user ||= organization.members.find_by_user_id(@user_id)
  end

end
