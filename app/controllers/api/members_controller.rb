class Api::MembersController < ApiController

  # get /api/tasks
  def index
    if group.present?
      members = group.members
    else
      members = organization.members
    end
    render json: Api::MembersSerializer[members.all]
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id)
  end
end
