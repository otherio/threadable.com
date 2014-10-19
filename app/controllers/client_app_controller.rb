class ClientAppController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  layout 'client_app'

  def show
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      raise ActionController::RoutingError.new('Not Found')
    end
    return redirect_to sign_in_path(r: request.url) unless signed_in?

    @realtime_token = UpdateRealtimeToken.call(threadable, session)
    @realtime_url = Rails.configuration.realtime[:url]
  end

end
