class InvitesController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json

  # POST /projects/make-a-tank/invites.json
  def create
    @user = User.find_or_initialize_by_email(params[:user])

    if @user.new_record?
      @user.password_required = false
      @user.save!
    end

    project.members << @user

    respond_with @user, status: :created
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
