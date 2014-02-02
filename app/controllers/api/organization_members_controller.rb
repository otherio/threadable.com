class Api::OrganizationMembersController < ApiController

  def index
    render json: serialize(:organization_members, organization.members.all)
  end

  def create
    member_params = params.require(:organization_member).permit(:name, :email_address, :personal_message).symbolize_keys

    user = covered.users.find_by_email_address(member_params[:email_address])

    if user && organization.members.include?(user)
      return render json: {error: "user is already a member"}, status: :unprocessable_entity
    end

    member = organization.members.add(member_params)
    render json: serialize(:organization_members, member), status: 201

  rescue Covered::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

end
