class InvitesController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json

  # POST /projects/make-a-tank/invites.json
  def create
    email = params.require(:invite)[:email]
    name  = params.require(:invite)[:name]

    @user = User.with_email(email).first_or_initialize(name: name, email: email)

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
    @project ||= current_user.projects.where(slug: params[:project_id]).first!
  end

end
