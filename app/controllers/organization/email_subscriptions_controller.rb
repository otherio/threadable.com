class Organization::EmailSubscriptionsController < ApplicationController

  before_filter :deal_with_robots!

  # GET /:organization_id/unsubscribe/:token
  def unsubscribe
    organization_id, member_id = OrganizationUnsubscribeToken.decrypt(params.require(:token))
    covered.current_user_id ||= member_id
    @organization = current_user.organizations.find_by_id! organization_id
    @member  = @organization.members.me
    @resubscribe_token = OrganizationResubscribeToken.encrypt(@organization.id, @member.id)
    if @member.subscribed?
      @member.unsubscribe!
      covered.emails.send_email_async(:unsubscribe_notice, @organization.id, @member.id)
    end
  end

  # GET /:organization_id/resubscribe/:token
  def resubscribe
    organization_id, member_id = OrganizationResubscribeToken.decrypt(params.require(:token))
    covered.current_user_id ||= member_id
    @organization = current_user.organizations.find_by_id! organization_id
    @member  = @organization.members.me
    @member.subscribe!(true) unless @member.subscribed?
  end

  private

  def deal_with_robots!
    render :auto_post, layout: false if request.get?
  end

end
