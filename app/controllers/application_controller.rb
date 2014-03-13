class ApplicationController < ActionController::Base

  protect_from_forgery

  include RedirectViaJavascriptConcern
  include AuthenticationConcern
  include TrackingConcern
  include RescueFromExceptionsConcern
  include DebugCookie

  before_action do
    return unless request.get?
    request_url = URI.parse(request.url)
    legal_hosts = case
    when Rails.env.production?;  ['threadable.com']
    when Rails.env.staging?;     ['staging.threadable.com']
    when Rails.env.development?; ['127.0.0.1']
    when Rails.env.test?;        ['test.host', '127.0.0.1']
    else return
    end
    return if legal_hosts.include?(request_url.host)
    request_url.host = legal_hosts.first
    redirect_to request_url.to_s
  end

  before_action :ensure_mixpanel_distinct_id_is_correct!
  before_action :require_user_be_signed_in!


  def inspect
    %(#<#{self.class} #{request.request_method} #{request.url} #{params.inspect[1..-2]}>) rescue super
  end

end
