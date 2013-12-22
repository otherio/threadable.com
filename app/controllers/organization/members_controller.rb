class Organization::MembersController < ApplicationController

  before_filter :require_user_be_signed_in!

  # GET /projects/make-a-tank/members
  # GET /projects/make-a-tank/members.json
  def index
    @members = project.members.all

    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  # POST /projects/make-a-tank/members.json
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

    if user && project.members.include?(user)
      return render json: {error: "user is already a member"}, status: :unprocessable_entity
    end

    member = project.members.add(member_params)
    render json: member, status: :created
  rescue Covered::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  end

  # DELETE /projects/make-a-tank/members.json
  def destroy
    project.members.remove user_id: params[:id]
    head :no_content
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
