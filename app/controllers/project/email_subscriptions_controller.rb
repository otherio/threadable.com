class Project::EmailSubscriptionsController < ApplicationController

  before_filter :deal_with_robots!

  # GET /:project_id/unsubscribe/:token
  def unsubscribe
    project_membership_id = ProjectUnsubscribeToken.decrypt(params.require(:token))
    project_membership = Covered::ProjectMembership.find(project_membership_id)
    @project = project_membership.project
    @member = project_membership.user
    @resubscribe_token = ProjectResubscribeToken.encrypt(project_membership.id)
    if project_membership.gets_email?
      project_membership.update_attribute(:gets_email, false)
      covered.send_email(:unsubscribe_notice, project_id: @project.id, recipient_id: @member.id)
    end
  end

  # GET /:project_id/resubscribe/:token
  def resubscribe
    project_membership_id = ProjectResubscribeToken.decrypt(params.require(:token))
    project_membership = Covered::ProjectMembership.find(project_membership_id)
    @project = project_membership.project
    @member = project_membership.user
    project_membership.update_attribute(:gets_email, true) unless project_membership.gets_email?
  end

  private

  def deal_with_robots!
    render :auto_post, layout: false if request.get?
  end

end
