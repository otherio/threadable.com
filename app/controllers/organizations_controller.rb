class OrganizationsController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :require_user_be_signed_in_or_have_a_sign_up_confirmation_token!
  before_action :decrypy_sign_up_confirmation_token!

  # GET /create
  def new
    @new_organization = NewOrganization.new(threadable)
    @new_organization.organization_name = params[:organization_name] || @organization_name
    @new_organization.your_email_address = @email_address unless signed_in?
  end

  # POST /create
  def create
    new_organization_params = params.require(:new_organization).permit(
      :organization_name,
      :email_address_username,
      :your_name,
      :password,
      :password_confirmation,
      :members,
    )
    # rails is stupid
    new_organization_params[:members] = params[:new_organization][:members] if params[:new_organization][:members].present?
    @new_organization = NewOrganization.new(threadable, new_organization_params)
    @new_organization.your_email_address = @email_address unless signed_in?
    if @new_organization.create
      sign_in! @new_organization.creator unless signed_in?
      redirect_to conversations_url(@new_organization.organization, 'my')
    else
      render :new
    end
  end

  private

  def require_user_be_signed_in_or_have_a_sign_up_confirmation_token!
    return if signed_in? || sign_up_confirmation_token.present?
    redirect_to sign_in_path(r: new_organization_path)
  end

  def decrypy_sign_up_confirmation_token!
    return unless sign_up_confirmation_token
    @organization_name, @email_address = SignUpConfirmationToken.decrypt(sign_up_confirmation_token)
  end

  def sign_up_confirmation_token
    params[:token].presence
  end
  helper_method :sign_up_confirmation_token

end
