class Organization::EmailSubscriptionsController < ApplicationController

  include ForwardGetRequestsAsPostsConcern
  skip_before_action :require_user_be_signed_in!
  before_action :forward_get_requests_as_posts!
  before_action :decrypt_token!

  # GET /:organization_id/unsubscribe/:token
  def unsubscribe
    @resubscribe_token = OrganizationResubscribeToken.encrypt(@organization.id, @member.id)
    if @member.subscribed?
      @member.unsubscribe!
      threadable.emails.send_email_async(:unsubscribe_notice, @organization.id, @member.id)
    end
  end

  # GET /:organization_id/resubscribe/:token
  def resubscribe
    @member.subscribe! unless @member.subscribed?
  end

  private

  def decrypt_token!
    organization_id, member_id = case action_name.to_sym
    when :unsubscribe
      OrganizationUnsubscribeToken.decrypt(params.require(:token))
    when :resubscribe
      OrganizationResubscribeToken.decrypt(params.require(:token))
    end
    threadable.current_user_id ||= member_id
    @organization = current_user.organizations.find_by_id! organization_id
    @member = @organization.members.current_member
  end

end
