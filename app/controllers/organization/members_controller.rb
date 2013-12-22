class Organization::MembersController < ApplicationController

  before_filter :require_user_be_signed_in!

  # GET /organizations/make-a-tank/members
  # GET /organizations/make-a-tank/members.json
  def index
    @members = organization.members.all

    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  # POST /organizations/make-a-tank/members.json
  def create
    member_params = params.require(:member).permit(:id,:name,:email_address,:message).symbolize_keys

    member_params[:user_id]          = member_params.delete(:id)      if member_params.key? :id
    member_params[:personal_message] = member_params.delete(:message) if member_params.key? :message

    user = case
    when member_params[:email_address]
      covered.users.find_by_email_address(member_params[:email_address])
    when member_params[:user_id]
      covered.users.find_by_id(member_params[:user_id])
    end

    if user && organization.members.include?(user)
      return render json: {error: "user is already a member"}, status: :unprocessable_entity
    end

    member = organization.members.add(member_params)
    render json: member, status: :created
  rescue Covered::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  # DELETE /organizations/make-a-tank/members.json
  def destroy
    organization.members.remove user_id: params[:id]
    head :no_content
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

end
