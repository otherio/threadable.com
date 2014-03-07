class SignUpController < ApplicationController

  skip_before_filter :require_user_be_signed_in!

  def sign_up
    sign_up_params = params.require(:sign_up).permit(:organization_name, :email_address)
    sign_up = SignUp.new(threadable, sign_up_params)

    return render(json: {errors: sign_up.errors.as_json}, status: :not_acceptable) if !sign_up.valid?

    threadable.track('Homepage sign up',
      email_address:     sign_up.email_address,
      organization_name: sign_up.organization_name,
    )

    if sign_up.existing_user?
      render(json: {
        redirect_to: sign_in_path(
          notice: "You already have an account. Please sign in.",
          r: new_organization_path(organization_name: sign_up.organization_name), email_address: sign_up.email_address
        )
      })
    else
      threadable.emails.send_email_async(:sign_up_confirmation, sign_up.organization_name, sign_up.email_address)
      render nothing: true, status: :created
    end
  end

  include ForwardGetRequestsAsPostsConcern
  before_action :forward_get_requests_as_posts!, only: :confirmation
  def confirmation
    organization_name, email_address = SignUpConfirmationToken.decrypt(params[:token])
    sign_out!
    user = threadable.users.find_by_email_address(email_address)
    if user
      user.email_addresses.find_by_address!(email_address).confirm!
      sign_in! user
    else
      threadable.email_addresses.find_or_create_by_address!(email_address).confirm!
    end
    redirect_to new_organization_url(token: params[:token])
  end

end
