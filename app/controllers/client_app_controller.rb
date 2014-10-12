class ClientAppController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  layout 'client_app'

  def show
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      raise ActionController::RoutingError.new('Not Found')
    end
    return redirect_to sign_in_path(r: request.url) unless signed_in?

    update_realtime_token!
    @realtime_url = Rails.configuration.realtime[:url]
  end

  private

  def realtime_token
    @realtime_token ||= Digest::SHA1.hexdigest("#{session[:session_id]}:#{threadable.current_user_id}")
  end

  def update_realtime_token!
    user_id = threadable.current_user_id

    session_data = {
      user_id: user_id,
      organization_ids: threadable.current_user.organizations.all.map(&:id)
    }.to_json

    Threadable.redis.hset(
      "realtime_session-#{user_id}",
      realtime_token,
      session_data
    )

    Threadable.redis.expire("realtime_session-#{realtime_token}", 86400)
  end

end
