class Admin::OrganizationsController < ApplicationController

  before_filter :require_user_be_admin!

  # GET /admin/organizations
  def index
    @organizations = covered.organizations.all
  end

  # GET /admin/organizations/new
  def new
    @organization = covered.organizations.new
  end

  # POST /admin/organizations
  def create
    @organization = covered.organizations.create(organization_params)

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
    @all_users = covered.users.all
  end

  # PATCH /admin/organizations/1
  def update
    if organization.update(organization_params)
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
    @organization ||= covered.organizations.find_by_slug! params[:id]
  end

  def organization_params
    @organization_params or begin
      @organization_params = params.require(:organization).permit(
        :name,
        :subject_tag,
        :slug,
        :email_address_username,
        :add_current_user_as_a_member,
      ).symbolize_keys
      if @organization_params.key? :add_current_user_as_a_member
        @organization_params[:add_current_user_as_a_member] = @organization_params[:add_current_user_as_a_member] == "1"
      end
    end
    @organization_params
  end

  # this is here so the page navigation organization section is not rendered
  def current_organization
  end
  helper_method :current_organization

end