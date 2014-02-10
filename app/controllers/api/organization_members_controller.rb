class Api::OrganizationMembersController < ApiController

  def index
    render json: serialize(:organization_members, organization.members.all)
  end

  def create
    member_params = params.require(:organization_member).permit(:name, :email_address, :personal_message)

    user = threadable.users.find_by_email_address(member_params[:email_address])

    if user && organization.members.include?(user)
      return render json: {error: "user is already a member"}, status: :unprocessable_entity
    end

    member = organization.members.add(member_params)
    render json: serialize(:organization_members, member), status: 201

  rescue Threadable::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  def update
    organization
    member_params = params.require(:organization_member).permit(:slug, :is_subscribed)
    member = organization.members.find_by_user_slug!(member_params[:slug])
    member_params[:is_subscribed] ? member.subscribe!(true) : member.unsubscribe!(true)
    render json: serialize(:organization_members, member)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

end
