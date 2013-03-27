class InvitesController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json

  # POST /projects/make-a-tank/invites.json
  def create
    @user = User.find_or_initialize_by_email(params[:invite].slice(:email, :name))

    if @user.new_record?
      @user.password_required = false
      @user.save!
    end

    project.project_memberships.create(:user => @user, :gets_email => false)

    UserMailer.invite_notice(
      project: @project,
      sender: current_user,
      user: @user,
      host: request.host,
      port: request.port,
      invite_message: params[:invite][:invite_message]
    ).deliver

    respond_with @user, status: :created
  rescue ActiveRecord::RecordNotUnique
    respond_with @user, status: :bad_request
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
