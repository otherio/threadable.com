class Admin::OrganizationsController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  # GET /admin/organizations
  def index
    @organizations = threadable.organizations.all_by_created_at
  end

  # GET /admin/organizations/new
  def new
    @organization = threadable.organizations.new
  end

  # POST /admin/organizations
  def create
    @organization = threadable.organizations.create(organization_params)

    if organization.persisted?
      redirect_to admin_edit_organization_path(organization), notice: 'Organization was successfully created.'
    else
      render action: 'new'
    end
  end

  # GET /admin/organizations/1/edit
  def edit
    organization
    @members = organization.members.all
    @all_users = threadable.users.all
  end

  # PATCH /admin/organizations/1
  def update
    if organization.admin_update(organization_params)
      redirect_to admin_edit_organization_path(organization), notice: 'Organization was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/organizations/1
  def destroy
    organization.destroy!
    redirect_to admin_organizations_url, notice: 'Organization was successfully destroyed.'
  end

  private

  def organization
    @organization ||= threadable.organizations.find_by_slug! params[:id]
  end

  def organization_params
    @organization_params or begin
      @organization_params = params.require(:organization).permit(
        :name,
        :subject_tag,
        :slug,
        :email_address_username,
        :add_current_user_as_a_member,
        :trusted,
        :hold_all_messages,
        :plan,
        :description,
        :public_signup,
        :searchable,
        :billforward_account_id,
        :billforward_subscription_id,
        :account_type,
      ).symbolize_keys
      if @organization_params.key? :add_current_user_as_a_member
        @organization_params[:add_current_user_as_a_member] = @organization_params[:add_current_user_as_a_member] == "1"
      end
      if @organization_params.key? :trusted
        @organization_params[:trusted] = @organization_params[:trusted] == "1"
      end
    end
    @organization_params
  end

end
