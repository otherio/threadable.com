class Organization::EmailSubscriptionsController < ApplicationController

  before_filter :deal_with_robots!

  # GET /:organization_id/unsubscribe/:token
  def unsubscribe
    organization_id, member_id = OrganizationUnsubscribeToken.decrypt(params.require(:token))
    threadable.current_user_id ||= member_id
    @organization = current_user.organizations.find_by_id! organization_id
    @member = @organization.members.current_member
    @resubscribe_token = OrganizationResubscribeToken.encrypt(@organization.id, @member.id)
    if @member.subscribed?
      @member.unsubscribe!
      threadable.emails.send_email_async(:unsubscribe_notice, @member.id, @organization.id)
    end
  end

  # GET /:organization_id/resubscribe/:token
  def resubscribe
    organization_id, member_id = OrganizationResubscribeToken.decrypt(params.require(:token))
    threadable.current_user_id ||= member_id
    @organization = current_user.organizations.find_by_id! organization_id
    @member = @organization.members.current_member
    @member.subscribe! unless @member.subscribed?
  end

  private

  def deal_with_robots!
    render :auto_post, layout: false if request.get?
  end

end
