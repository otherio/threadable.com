class Project::EmailSubscriptionsController < ApplicationController

  before_filter :deal_with_robots!

  # GET /:project_id/unsubscribe/:token
  def unsubscribe
    project_id, member_id = ProjectUnsubscribeToken.decrypt(params.require(:token))
    covered.current_user_id ||= member_id
    @project = current_user.projects.find_by_id! project_id
    @member  = @project.members.me
    @resubscribe_token = ProjectResubscribeToken.encrypt(@project.id, @member.id)
    if @member.subscribed?
      @member.unsubscribe!
      covered.emails.send_email_async(:unsubscribe_notice, @project.id, @member.id)
    end
  end

  # GET /:project_id/resubscribe/:token
  def resubscribe
    project_id, member_id = ProjectResubscribeToken.decrypt(params.require(:token))
    covered.current_user_id ||= member_id
    @project = current_user.projects.find_by_id! project_id
    @member  = @project.members.me
    @member.subscribe! unless @member.subscribed?
  end

  private

  def deal_with_robots!
    render :auto_post, layout: false if request.get?
  end

end
