class Users::ConfirmController < ApplicationController

  before_filter :sign_out_if_signed_in!
  before_filter :require_valid_token!

  def confirm
    user.confirm! unless user.confirmed?
    flash[:notice] = 'Your account has been confirmed!'

    if user.requires_setup?
      user_setup_token = UserSetupToken.encrypt(user.id, root_path)
      redirect_to setup_users_path(user_setup_token)
    else
      redirect_to sign_in_path(email: user.email)
    end
  end

  private

  def require_valid_token!
    render :confirmation_failed if user_id.blank?
  end

  def user_id
    return @user_id if defined?(@user_id)
    @user_id = UserConfirmationToken.decrypt(params[:token])
  rescue Token::Invalid
  end

  def user
    @user ||= Covered::User.where(id: user_id).first! if user_id
  end

end
