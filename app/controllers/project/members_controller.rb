class Project::MembersController < ApplicationController

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

    personal_message = member_params.delete(:message)
    member = project.members.add(member_params, personal_message)

    render json: member, status: :created
  rescue Covered::RecordInvalid
    render json: {error: "unable to create user"}, status: :unprocessable_entity
  rescue Covered::UserAlreadyAMemberOfProjectError
    render json: {error: "user is already a member"}, status: :unprocessable_entity
  end

  # DELETE /projects/make-a-tank/members.json
  def destroy
    project.members.remove(params[:id])
    head :no_content
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
