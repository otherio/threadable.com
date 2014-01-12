class Api::GroupsController < ApiController

  # get /api/groups
  def index
    render json: Api::GroupsSerializer[organization.groups.all, current_user.group_ids]
  end

  # post /api/groups
  def create
    group_params = params[:group].permit(:color, :name)
    group_params.require :name
    group = organization.groups.create name: group_params[:name], color: group_params[:color]
    if group.persisted?
      render json: Api::GroupsSerializer[group], status: 201
    else
      render nothing: true, status: 409
    end
  end

  # get /api/groups/:id
  def show
    group = organization.groups.find_by_email_address_tag!(params[:id])
    render json: Api::GroupsSerializer[group, current_user.group_ids]
  end

  # patch /api/groups/:id
  def update
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group.update(color: params[:group][:color]) #the only thing you can change right now.
    render json: Api::GroupsSerializer[group, current_user.group_ids], status: 200
  end

  def destroy
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group.destroy
    render nothing: true, status: 204
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

end
