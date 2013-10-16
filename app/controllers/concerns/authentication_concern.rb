module AuthenticationConcern

  extend ActiveSupport::Concern

  AuthorizationError = Covered::AuthorizationError

  included do
    helper_method :current_user
    rescue_from AuthorizationError, with: :rescue_from_authorization_error
  end

  private

  def current_user_id
    session[:user_id] ||= decrypt_remember_me_cookie!
  end

  def current_user
    @current_user ||= User.where(id: current_user_id).first! if signed_in?
  rescue ActiveRecord::RecordNotFound
    sign_out!
    unauthorized!
  end

  def sign_in! user, remember_me: false
    user_id = case user
    when User; user.id
    when Integer; user
    else raise ArgumentError, "invalid user #{user.inspect}"
    end
    session[:user_id] = user_id
    cookies.permanent[:remember_me] = RememberMeToken.encrypt(user_id) if remember_me
    true
  end

  def sign_out!
    @current_user = nil
    session.delete(:user_id)
    cookies.delete(:remember_me)
  end

  def signed_in?
    current_user_id.present?
  end

  def unauthorized! message=nil
    raise AuthorizationError, message
  end

  def require_user_be_signed_in!
    unauthorized! unless signed_in?
  end

  def require_user_not_be_signed_in!
    redirect_to root_path if signed_in?
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

  protected

  def rescue_from_authorization_error exception
    logger.debug "#{exception.class}, #{exception.message}"
    if signed_in?
      flash[:error] = exception.message || 'You are not authorized to do that.'
      redirect_to root_path
    else
      redirect_to sign_in_path(r:request.url)
    end
  end

end
