class ProfileController < ApplicationController

  layout 'new'

  before_filter :require_user_be_signed_in!

  def show
    @external_authorizations = current_user.external_authorizations.all
    @google_auth = @external_authorizations.find { |a| a.provider == 'google_oauth2' }
    @trello = @external_authorizations.find { |a| a.provider == 'trello' }
    @expand = params[:expand_section]
  end

  def update
    user_params = params.require(:user)

    case
    when user_params.key?(:name)
      current_user.update user_params.permit(:name, :munge_reply_to, :show_mail_buttons, :secure_mail_buttons)
      notice = "We've updated your profile"
    when user_params.key?(:current_password)
      @expand = 'password'

      current_user.change_password user_params.permit(:current_password, :password, :password_confirmation)
      notice = "We've changed your password"
    end

    if current_user.errors.any?
      flash.now[:error] = "Error updating profile. See below."
    else
      flash.now[:notice] = notice
    end

    render :show
  end

end
