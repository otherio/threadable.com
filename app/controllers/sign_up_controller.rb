class SignUpController < ApplicationController

  skip_before_filter :require_user_be_signed_in!

  def show
    return redirect_to root_path if signed_in?
    # TEMP this form will later be on the home page
    threadable.track(:sign_up_page_visited)
  end

  def sign_up
    return redirect_to root_path if signed_in?
    sign_up_params = params.require(:sign_up).permit(:organization_name, :email_address)
    organization_name = sign_up_params.require(:organization_name)
    email_address = sign_up_params.require(:email_address)

    email_address_record = EmailAddress.find_or_initialize_by(address: email_address)
    if email_address_record.persisted? && email_address_record.user.present?
      redirect_to sign_in_path(
        email_address: email_address,
        r: new_organization_path(organization_name: organization_name),
        notice: "You already have an account. Please sign in.",
      )
      threadable.track(:sign_up,
        organization_name: organization_name,
        email_address: email_address,
        result: 'redirected to sign in page',
      )
    else
      email_address_record.save!
      threadable.emails.send_email_async(:sign_up_confirmation, organization_name, email_address)
      render :thank_you
      threadable.track(:sign_up,
        organization_name: organization_name,
        email_address: email_address,
        result: 'rendered thank you and sent email',
      )
    end

  end

end




# single sign up form with just email address
# that creates an email address record and
#   sends a signup email confirmation with a token
#   that token goes to the org create page with added name and password fields
