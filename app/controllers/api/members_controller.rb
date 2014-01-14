class Api::MembersController < ApiController

  # get /api/tasks
  def index
    members = group.present? ? group.members : organization.members
    render json: serialize(:members, members.all)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id)
  end
end
