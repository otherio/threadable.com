class Api::MembersController < ApiController

  def index
    members = group.present? ? group.members : organization.members
    render json: serialize(:members, members.all)
  end

  def create
    member_params = params.require(:member).permit(:name, :email_address, :personal_message).symbolize_keys

    user = covered.users.find_by_email_address(member_params[:email_address])

    if user && organization.members.include?(user)
      return render json: {error: "user is already a member"}, status: :unprocessable_entity
    end

    member = organization.members.add(member_params)
    render json: serialize(:members, member), status: 201

  rescue Covered::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id)
  end
end
