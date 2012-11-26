class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  before_filter :setup_multify_authentication_token

  def self.require_authentication! options={}
    before_filter :require_authentication!, options
  end

  def require_authentication!
    render nothing: true, status: :not_found if !authenticated?
  end

  def current_user_id
    session[:current_user_id]
  end

  def current_user
    @current_user ||= Multify::User.find(id: current_user_id) if current_user_id.present?
  end
  helper_method :current_user

  def authenticated?
    current_user.present?
  end
  helper_method :authenticated?

  def authenticate email, password
    authentication_token, user = Multify.authenticate(
      email,
      password
    )
    session[:authentication_token] = authentication_token
    session[:current_user_id] = user.id
    user
  rescue RestClient::ResourceNotFound
    false
  end

  def setup_multify_authentication_token
    Multify.authentication_token = session[:authentication_token]
  end

  rescue_from 'RecordNotFound' do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
    end
  end

end
