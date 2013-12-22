class Admin::Organization::MembersController < ApplicationController

  before_filter :require_user_be_admin!
  before_filter :find_or_create_user!, only: :add

  # POST /admin/projects/:project_slug/members
  def add
    if project.members.include? user
      flash[:alert] = "#{user.formatted_email_address} is already a meber of #{project.name}."
    else
      member = project.members.add(
        user: user,
        gets_email: member_params[:gets_email],
        send_join_notice: member_params[:send_join_notice],
      )
      flash[:notice] = "#{member.formatted_email_address} was successfully added to #{project.name}."
    end
    redirect_to admin_edit_project_path(project)
  end

  # PATCH /admin/projects/:project_slug/members/:user_id
  def update
    member = project.members.find_by_user_id! params[:user_id]
    if member.update(member_params)
      flash[:notice] = "update of #{member.formatted_email_address} membership to #{project.name} was successful."
    else
      flash[:alert] = "update of #{member.formatted_email_address} membership to #{project.name} was unsuccessful."
    end
    redirect_to admin_edit_project_path(project)
  end

  # DELETE /admin/projects/:project_slug/members/:user_id
  def remove
    user_id = params.require(:user_id).to_i
    if member = project.members.find_by_user_id(user_id)
      project.members.remove(user: member)
      flash[:notice] = "#{member.formatted_email_address} was successfully removed from #{project.name}."
    else
      flash[:alert] = "user #{user_id} is not a member of #{project.name}."
    end
    redirect_to admin_edit_project_path(project)
  end

  private

  def project
    @project ||= covered.projects.find_by_slug! params[:project_id]
  end

  def member_params
    @member_params or begin
      @member_params = params.require(:user).permit(:id, :name, :email_address, :gets_email, :send_join_notice).symbolize_keys
      @member_params[:gets_email]       = @member_params[:gets_email] == 'true'
      @member_params[:send_join_notice] = @member_params[:send_join_notice] == 'true'
    end
    @member_params
  end

  attr_reader :user
  def find_or_create_user!
    @user ||= if member_params.key?(:id)
      covered.users.find_by_id!(member_params[:id].to_i)
    else
      covered.users.find_by_email_address(member_params[:email_address]) or
      covered.users.create!(name: member_params[:name], email_address: member_params[:email_address])
    end
  rescue Covered::RecordNotFound
    redirect_to admin_edit_project_path(project), alert: "unable to find user #{member_params[:id]}"
  end

end
