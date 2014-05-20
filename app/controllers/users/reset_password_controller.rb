class Users::ResetPasswordController < ApplicationController

  skip_before_action :require_user_be_signed_in!, only: [:request_link, :show, :reset]

  def request_link
    email = params.require(:password_recovery).require(:email)
    user = User.with_email_address(email).first

    case
    when user && user.has_password?
      threadable.emails.send_email_async(:reset_password, user.id)
    when user
      threadable.emails.send_email_async(:reset_password, user.id)
    end

    render :request_link
  end

  def show
    user = User.where(id: user_id_from_token).first
    if user.nil?
      redirect_to root_url
    else
      sign_in! user
    end
  end

  def reset
    unauthenticated! if current_user_id != user_id_from_token
    attributes = params.require(:user).permit(:password, :password_confirmation)
    if current_user.update(attributes)
      flash[:notice] = 'Your password has been updated'
      unconfirmed_organizations = current_user.organizations.unconfirmed
      if unconfirmed_organizations.present?
        unconfirmed_organizations.each do |organization|
          organization.confirm!
        end
        redirect_to confirm_organizations_path
      else
        redirect_to root_path
      end
    else
      render :show
    end
  end

  def confirm_organizations
    render :confirm_organizations
  end

  private

  def user_id_from_token
    ResetPasswordToken.decrypt(params[:token])
  end

end
