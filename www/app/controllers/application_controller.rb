class ApplicationController < ActionController::Base
  protect_from_forgery

  private

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


  def login user_id
    session[:current_user_id] = user_id
  end

  rescue_from 'RecordNotFound' do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
    end
  end

end
