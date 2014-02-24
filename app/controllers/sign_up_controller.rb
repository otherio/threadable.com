class SignUpController < ApplicationController

  skip_before_filter :require_user_be_signed_in!

  def show
    redirect_to root_path if signed_in?
    # TEMP this form will later be on the home page
  end

  def sign_up
    sign_up_params = params.require(:sign_up).permit(:organization_name, :email_address)
    organization_name = sign_up_params.require(:organization_name)
    email_address = sign_up_params.require(:email_address)

    email_address_record = EmailAddress.find_or_initialize_by(address: email_address)
    if email_address_record.persisted? && email_address_record.user.present?
      redirect_to sign_in_path(email_address: email_address, r: new_organization_path(organization_name: organization_name))
    else
      email_address_record.save!
      threadable.emails.send_email_async(:sign_up_confirmation, organization_name, email_address)
      render :thank_you
    end
  end

end




# single sign up form with just email address
# that creates an email address record and
#   sends a signup email confirmation with a token
#   that token goes to the org create page with added name and password fields
