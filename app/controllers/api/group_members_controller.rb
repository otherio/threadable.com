class Api::GroupMembersController < ApiController

  # get /api/groups/:group_id/members
  def index
    render json: serialize(:group_members, group.members.all)
  end

  # post /api/groups/:group_id/members
  def create
    member = organization.members.find_by_user_id!(params.require(:user_id))
    member = group.members.add(member)
    render json: serialize(:group_members, member), status: 201
  end

  def update
    member_params = params.require(:group_member).permit(:user_id, :gets_in_summary)
    member = group.members.find_by_user_id!(member_params[:user_id])
    member_params[:gets_in_summary] ? member.gets_in_summary! : member.gets_every_message!
    render json: serialize(:group_members, member)
  end

  # delete /api/groups/:group_id/members
  def destroy
    member = group.members.find_by_user_id!(params.require(:id))
    group.members.remove(member)
    render nothing: true, status: 204
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

  def group
    @group ||= organization.groups.find_by_slug!(params.require(:group_id))
  end

end
