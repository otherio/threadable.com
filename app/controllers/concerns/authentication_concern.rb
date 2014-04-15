module AuthenticationConcern

  extend ActiveSupport::Concern

  included do
    include TrackingConcern
    helper_method :threadable, :current_user, :signed_in?
  end

  def current_user_id
    session[:user_id] ||= doorkeeper_token.try(:resource_owner_id) || decrypt_remember_me_cookie!
  end

  def current_user
    threadable.current_user
  end

  def threadable
    @threadable ||= Threadable.new(
      host:            request.host,
      port:            request.port,
      protocol:        request_protocol,
      current_user_id: current_user_id,
      tracking_id:     mixpanel_distinct_id,
    )
  end

  def sign_in! user, remember_me: false
    user_id = case user; when Integer, String; user; else; user.id; end
    user_id or raise ArgumentError, "unable to determine user id from: #{user.inspect}"
    @threadable = nil
    session[:user_id] = user_id
    cookies.permanent[:remember_me] = RememberMeToken.encrypt(user_id) if remember_me
    mixpanel_cookie.distinct_id = user_id
    true
  end

  def sign_out!
    return unless signed_in?
    @threadable = nil
    session.delete(:user_id)
    cookies.delete(:remember_me)
    mixpanel_cookie.reset!
    true
  end

  def signed_in?
    current_user_id.present?
  end

  def admin?
    signed_in? && current_user.admin?
  end

  def unauthorized! message=nil
    raise Threadable::AuthorizationError, message
  end

  def unauthenticated! message=nil
    raise Threadable::AuthenticationError, message
  end

  def not_found! message=nil
    raise Threadable::RecordNotFound, message
  end

  def require_user_be_signed_in!
    unauthenticated! unless signed_in?
  end

  def require_user_be_admin!
    unauthorized! unless admin?
  end

  def require_user_not_be_signed_in!
    unauthorized! if signed_in?
  end

  def decrypt_remember_me_cookie!
    remember_me_token = cookies[:remember_me] or return nil
    RememberMeToken.decrypt(remember_me_token)
  rescue Token::Invalid
    cookies.delete(:remember_me)
    nil
  end

  def sign_out_if_signed_in!
    sign_out! if signed_in?
  end

  def request_protocol
    request.protocol.gsub(%r{://}, '')
  end

end
