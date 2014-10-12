class ClientAppController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :update_realtime_token!

  layout 'client_app'

  def show
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      raise ActionController::RoutingError.new('Not Found')
    end
    redirect_to sign_in_path(r: request.url) unless signed_in?

    @realtime_url = 'http://127.0.0.1:5001'
  end

  private

  def realtime_token
    @realtime_token ||= Digest::MD5.hexdigest("#{session[:session_id]}:#{threadable.current_user_id}")
  end

  def update_realtime_token!
    user_id = threadable.current_user_id

    session_data = {
        "user_id" => user_id,
    }.to_json

    Threadable.redis.hset(
      "rtSession-#{user_id}",
      realtime_token,
      session_data
    )

    Threadable.redis.expire("rtSession-#{user_id}", 86400)
  end

end
