class Api::OrganizationsController < ApiController

  # get /api/organizations
  def index
    render json: serialize(:organizations, current_user.organizations.all)
  end

  # post /api/organizations
  def create

  end

  # get /api/organizations/:id
  def show
    organization = current_user.organizations.find_by_slug!(params[:id])
    render json: serialize(:organizations, organization)
  end

  # patch /api/organizations/:id
  def update

  end

  # delete /api/organizations/:id
  def destroy

  end

  def claim_google_account
    organization = current_user.organizations.find_by_slug!(params[:organization_id])
    organization.google_user = organization.members.current_member
    render json: serialize(:organizations, organization)
  end

end
