class EmailSubscriptionsController < ApplicationController

  before_filter :decrypt_token

  # GET /:project_id/unsubscribe/:token
  def unsubscribe
    if @project_membership.gets_email
      @project_membership.gets_email = false
      @project_membership.save!
      UserMailer.unsubscribe_notice(
        project: @project,
        user: @user,
        host: request.host,
        port: request.port,
      ).deliver
    end
  end

  # GET /:project_id/subscribe/:token
  def subscribe
    @project_membership.gets_email = true
    @project_membership.save!
  end

  private

  def project
    @project ||= Project.find_by_slug!(params[:project_id])
  end

  def decrypt_token
    @unsubscribe_token = params[:token]
    project_id, user_id = UnsubscribeToken.decrypt(@unsubscribe_token)
    project.id == project_id or raise "project ids don't match"
    @project_membership = project.project_memberships.where(user_id: user_id).includes(:user).first
    @user = @project_membership.user
  end

end
