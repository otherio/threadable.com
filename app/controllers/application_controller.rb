class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include TrackingConcern
  include RescueFromExceptionsConcern
  include DebugCookie

  before_action :redirect_from_organization_subdomain!
  before_action :redirect_from_unknown_host!
  before_action :ensure_mixpanel_distinct_id_is_correct!
  before_action :require_user_be_signed_in!


  def inspect
    %(#<#{self.class} #{request.request_method} #{request.url} #{params.inspect[1..-2]}>) rescue super
  end

  private

  def redirect_from_organization_subdomain!
    return unless request.get?
    request_url = URI.parse(request.url)
    return if legal_hosts.include?(request_url.host)
    slug_blacklist = ['www', 'blog', 'staging']  #TODO: make this be a real thing: https://www.pivotaltracker.com/story/show/62884858
    subdomain = request_url.host.split('.')[0]
    return if slug_blacklist.include?(subdomain)
    request_url.host = legal_hosts.first
    request_url.path = "/#{subdomain}/"
    redirect_to request_url.to_s
  end

  def redirect_from_unknown_host!
    return unless request.get?
    request_url = URI.parse(request.url)
    return if legal_hosts.include?(request_url.host)
    request_url.host = legal_hosts.first
    redirect_to request_url.to_s
  end

  def legal_hosts
    case
    when Rails.env.production?;  ['threadable.com']
    when Rails.env.staging?;     ['staging.threadable.com']
    when Rails.env.development?; ['127.0.0.1', 'threadable.local']
    when Rails.env.test?;        ['test.host', '127.0.0.1']
    else return
    end
  end

end
