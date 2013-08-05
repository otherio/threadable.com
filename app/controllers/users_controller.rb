class UsersController < ApplicationController

  before_filter :authenticate_user!, except: [:setup, :update]
  before_filter :authenticate_user!, only:   [:setup, :update], unless: :valid_user_setup_token_present?

  # def edit
  # end

  def setup
    @user = User.find(@user_id)
  end

  def update
    user_attributes = params.require(:user).permit(:name, :password, :password_confirmation)
    @user = User.where(slug: params[:id]).first!
    @user.password_required!

    if !@user.update_attributes(user_attributes)
      render user_setup_token.present? ? :setup : :edit
      return
    end

    if user_setup_token.present?
      @user.confirm!
      sign_in @user
      redirect_to @destination_path
    else
      redirect_to user_path(@user)
    end
  end

  private

  def user_setup_token
    return if params[:token].blank?
    if !defined?(@user_setup_token)
      @user_setup_token = params[:token]
      begin
        @user_id, @destination_path = UserSetupToken.decrypt(@user_setup_token)
      rescue Invalid::Token
        @user_setup_token = nil
      end
    end
    @user_setup_token
  end

  def valid_user_setup_token_present?
    user_setup_token.present?
  end

end
