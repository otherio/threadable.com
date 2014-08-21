class SignUpController < ApplicationController

  skip_before_filter :require_user_be_signed_in!

  layout 'new'

  def sign_up
    sign_up_params = params.require(:sign_up).permit(:organization_name, :email_address)
    sign_up = SignUp.new(threadable, sign_up_params)

    return render(json: {errors: sign_up.errors.as_json}, status: :not_acceptable) if !sign_up.valid?

    threadable.track('Homepage sign up',
      email_address:     sign_up.email_address,
      organization_name: sign_up.organization_name,
    )

    threadable.tracker.set_properties('$email' => sign_up.email_address)

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

  def show
    @organization = threadable.organizations.find_by_slug!(params[:organization_id])
    if !params[:view] && current_user_is_a_member?
      return redirect_to conversations_path(@organization.slug, 'my')
    end

    @view_only = params[:view] && current_user_is_a_member?

    if @organization.public_signup?
      render :show
    else
      raise Threadable::RecordNotFound
    end
  end

  def create
    @organization = threadable.organizations.find_by_slug!(params[:organization_id])

    if current_user_is_a_member?
      return redirect_to conversations_path(@organization.slug, 'my')
    end

    if current_user.present?
      @organization.members.add user: current_user, confirmed: true
      return redirect_to conversations_path(@organization.slug, 'my')
    else
      user_params = params.require(:sign_up)
      name = user_params.require(:name)
      email_address = user_params.require(:email_address)

      begin
        @organization.members.add name: name, email_address: email_address, confirmed: false
      rescue Threadable::RecordInvalid => e
        @error = 'Email address is invalid'
        return render :show
      end

      render :thank_you, status: :created
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

  private

  def current_user_is_a_member?
    @current_user_is_a_member ||= current_user.present? && @organization.members.include?(current_user)
  end

end
