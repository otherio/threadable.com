class ProfileController < ApplicationController

  layout 'old'

  before_filter :require_user_be_signed_in!

  def show
  end

  def update
    user_params = params.require(:user)

    case
    when user_params.key?(:name)
      current_user.update user_params.permit(:name, :munge_reply_to, :show_mail_buttons)
      notice = "We've updated your profile"
    when user_params.key?(:current_password)
      current_user.change_password user_params.permit(:current_password, :password, :password_confirmation)
      notice = "We've changed your password"
    end

    if current_user.errors.present?
      render :show
    else
      flash[:notice] = notice
      redirect_to profile_path
    end
  end

end
