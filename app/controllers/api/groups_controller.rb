class Api::GroupsController < ApiController

  # get /api/groups
  def index
    render json: serialize(:groups, organization.groups.all)
  end

  # post /api/groups
  def create
    group_params = params.require(:group).permit(:color, :name, :subject_tag, :email_address_tag, :auto_join)
    group = organization.groups.create(group_params)
    if group.persisted?
      render json: serialize(:groups, group), status: 201
    else
      render json: {error: group.group_record.errors.full_messages.to_sentence}, status: 406
    end
  end

  # get /api/groups/:id
  def show
    render json: serialize(:groups, group)
  end

  # patch /api/groups/:id
  def update
    group_params = params.require(:group).permit(:color, :name, :subject_tag, :auto_join)
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group.update(group_params)
    render json: serialize(:groups, group), status: 200
  end

  # post /api/groups/:id/join
  def join
    group.members.add(current_user) unless group.members.include? current_user
    render json: serialize(:groups, group)
  end

  # post /api/groups/:id/leave
  def leave
    group.members.remove(current_user) if group.members.include? current_user
    render json: serialize(:groups, group)
  end

  # delete /api/groups/:id
  def destroy
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group.destroy
    render nothing: true, status: 204
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_slug!(params[:id] || params[:group_id])
  end

end
