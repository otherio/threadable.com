class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include RescueFromExceptionsConcern
  include DebugCookie

  before_action do
    return unless request.get?
    request_url = URI.parse(request.url)
    legal_host = case
    when Rails.env.production?;  'threadable.com'
    when Rails.env.staging?;     'staging.threadable.com'
    when Rails.env.development?; '127.0.0.1'
    when Rails.env.test?;        '127.0.0.1'
    else return
    end
    return if request_url.host === legal_host
    request_url.host = legal_host
    redirect_to request_url.to_s
  end

  before_action :require_user_be_signed_in!

end
