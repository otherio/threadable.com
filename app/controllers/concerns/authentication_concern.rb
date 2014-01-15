module AuthenticationConcern

  extend ActiveSupport::Concern

  included do
    helper_method :covered, :current_user, :signup_enabled?
  end

  def current_user_id
    session[:user_id] ||= decrypt_remember_me_cookie!
  end

  def current_user
    covered.current_user
  end

  def covered
    @covered ||= Covered.new(current_user_id: current_user_id, host: request.host, port: request.port, protocol: request_protocol)
  end

  def sign_in! user, remember_me: false
    user_id = case user; when Integer, String; user; else; user.id; end
    @covered = nil
    session[:user_id] = user_id
    cookies.permanent[:remember_me] = RememberMeToken.encrypt(user_id) if remember_me
    true
  end

  def sign_out!
    @covered = nil
    session.delete(:user_id)
    cookies.delete(:remember_me)
  end

  def signed_in?
    current_user_id.present?
  end

  def admin?
    signed_in? && current_user.admin?
  end

  def signup_enabled?
    Rails.configuration.signup_enabled
  end

  def unauthorized! message=nil
    raise Covered::AuthorizationError, message
  end

  def unauthenticated! message=nil
    raise Covered::AuthenticationError, message
  end

  def not_found! message=nil
    raise Covered::RecordNotFound, message
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
