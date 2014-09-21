class SubscribeController < ApplicationController

  include EmberRouteUrlHelpers

  skip_before_action :require_user_be_signed_in!, only: [:callback]
  protect_from_forgery except: :callback

  def show
    billforward = Threadable::Billforward.new(organization: organization)

    if organization.billforward_subscription_id
      billforward.update_member_count
    else
      billforward.create_subscription
    end

    url = ENV['THREADABLE_BILLFORWARD_CHECKOUT_URL']
    redirect_to "#{url}/subscription/#{organization.billforward_subscription_id}?wanted_state=AwaitingPayment&redirect=#{organization_settings_url(organization)}&force_redirect=true"
  end

  def callback
    if params.require('domain') != 'Subscription'
      raise Threadable::RecordNotFound, 'Unsupported domain parameter'
    end

    subscription_id = params.require('entityID')

    billforward = Threadable::Billforward.new(subscription_id: subscription_id, threadable: threadable)
    billforward.update_paid_status

    render nothing: true, status: 200
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end
end
