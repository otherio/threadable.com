class Api::OrganizationsController < ApiController

  # get /api/organizations
  def index
    render json: Api::OrganizationsSerializer[current_user.organizations.all, current_user.group_ids]
  end

  # post /api/organizations
  def create

  end

  # get /api/organizations/:id
  def show
    organization = current_user.organizations.find_by_slug!(params[:id])
    render json: Api::OrganizationsSerializer[organization, current_user.group_ids]
  end

  # patch /api/organizations/:id
  def update

  end

  # delete /api/organizations/:id
  def destroy

  end

end
