class Users::ConfirmController < ApplicationController

  before_filter :sign_out_if_signed_in!
  before_filter :require_valid_token!

  def confirm
    current_user.confirm!
    flash[:notice] = 'Your account has been confirmed!'

    if current_user.requires_setup?
      user_setup_token = UserSetupToken.encrypt(current_user.id, root_path)
      redirect_to setup_users_path(user_setup_token)
    else
      sign_in! current_user
      redirect_to root_path
    end
  end

  private

  def require_valid_token!
    render :confirmation_failed if user_id.blank?
    covered.current_user_id = user_id
  end

  def user_id
    return @user_id if defined?(@user_id)
    @user_id = UserConfirmationToken.decrypt(params[:token])
  rescue Token::Invalid
  end

end
