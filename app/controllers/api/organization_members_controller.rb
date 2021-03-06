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

  rescue Threadable::RecordInvalid, ArgumentError
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  def destroy
    user = organization.members.find_by_user_id(params[:id])

    unless user && organization.members.include?(user)
      return render json: {error: "user is not a member"}, status: :unprocessable_entity
    end

    user.remove
    render json: {}, status: 200
  end

  def update
    member_params = params.require(:organization_member).permit(:slug, :subscribed, :role)
    member = organization.members.find_by_user_slug!(member_params.delete(:slug))
    member.update(member_params)
    render json: serialize(:organization_members, member)
  end

  def resend_invitation
    user = organization.members.find_by_user_id(params[:organization_member_id])

    unless user && organization.members.include?(user)
      return render json: {error: "user is not a member"}, status: :unprocessable_entity
    end

    unless user.confirmed?
      threadable.emails.send_email_async(:invitation, organization.id, user.id)
      render json: {}, status: 201
    else
      render json: {}, status: 200
    end

  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

end
